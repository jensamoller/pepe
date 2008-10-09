#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../../config/boot'

require 'rubygems'
require 'open-uri'
require 'hpricot'
require 'Player'
require 'htmlentities'

class Parser
  
  $coder = HTMLEntities.new()

  @doc
  @url
  @body_content_div
  
  def initialize(url)
    @url = url
    puts @url.to_s
    @doc = Hpricot.parse(get_response())
    
    @body_content_div = @doc.at("/html/body/div[@id='globalWrapper']/div[@id='column-content']/div[@id=content]/div[@id='bodyContent']")
    if(@body_content_div)
      infobox_table = @body_content_div.at("/table[@class='infobox vcard']")
      #puts "infobox_table: #{infobox_table}"

      if(infobox_table)
        is_club = infobox_table.at("tr[2]/th/a[@title='Football club names']")
        
        #sometimes the link is embedded in a span-tag :/
        if(is_club.nil?)
          is_club = infobox_table.at("tr[2]/th/span/a[@title='Football club names']")
        end

        if(!is_club.nil?)
          ClubParser.new(@doc, infobox_table, @url)
        else 
          if(is_in_football_category())
            if(!infobox_table.empty?)
              PlayerParser.new(@doc, infobox_table, @url).parse_player
            end
            @url.depth = 1
          else
            @url.depth = 2
          end
        end
      end

      if(@url.depth==1)
        find_links()
      end

    else
      puts "No body_content_div?: #{url}" 
    end

    url.visited = Time.now
    url.save
  end

  def is_in_football_category()
    
    output = false
    categories_div = @body_content_div.at("/div[@id='catlinks']")
    if(categories_div)
      output = categories_div.inner_html.include?("football")
      puts "is_in_football_category: #{output}"
    end
    return output
  end

  def find_links()
    
      @body_content_div.search('a[@href]').map { |link| 

        url_string = link['href']
        link_class = link['class'] 
        link_label = link.inner_html

        first_part = url_string[0, 6]
        second_part = url_string[6, 4]
        
        if(link_class!='new' and link_label!='edit' and first_part=="/w/ind" or (first_part=="/wiki/" and second_part!="User" and second_part!="Wiki" and second_part!="Help" and second_part!="Imag") )   
          
          existing_url = Url.find_by_url(url_string)
          
          #puts existing_url.nil?
          
          if(existing_url.nil?)
            the_url = Url.new()
            the_url.url = url_string;
            the_url.depth = 2
            the_url.save()
            
            #puts "saved new url: #{the_url}"
            
          end
        end
      }
  end

  def get_response()

    #puts @url.url
    # open-uri RDoc: http://stdlib.rubyonrails.org/libdoc/open-uri/rdoc/index.html
    open("http://en.wikipedia.org#{@url.url}", 
        "User-Agent" => "Mozilla/5.0 (Macintosh; U; Intel Mac OS X; da; rv:1.8.1.16) Gecko/20080702 Firefox/2.0.0.16") { |f|
        # Save the response body
        #puts f.read
        f.read
        
    }
  end

end