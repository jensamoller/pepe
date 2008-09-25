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
    
    #puts "@doc: #{@doc}"
    
    @body_content_div = @doc.at("/html/body/div[@id='globalWrapper']/div[@id='column-content']/div[@id=content]/div[@id='bodyContent']")
    if(@body_content_div)
      infobox_table =   @body_content_div.at("/table[@class='infobox vcard']")
      #puts "infobox_table: #{infobox_table}"

      if(infobox_table)

        is_club = infobox_table.at("tr[2]/th/a[@title='Football club names']")
        # puts "is_club: #{is_club}"
        if(is_club)
          ClubParser.new(@doc, infobox_table, @url)
        else 
          if(!infobox_table.empty?)
            PlayerParser.new(@doc, infobox_table, @url).parse_player
          elsif(url.url.index('ootball').nil?)
            @url.depth = 2
          else
            @url.depth = 1
          end
        end
      end

      #puts "infobox_table: #{infobox_table.empty?}"
      #puts url.url.index('ootball')
      #puts "url.depth after: #{@url.depth}"

      if(@url.depth==1)
        find_links()
      end

      url.visited = Time.now
      url.save
    else
      puts "No body_content_div?: #{@@doc.inner_html}" 
    end
  end

  def find_links()
    
      @body_content_div.search('a[@href]').map { |link| 

        url_string = link['href']
        link_class = link['class'] 
        link_label = link.inner_html

        first_part = url_string[0, 6]
        second_part = url_string[6, 4]
        
        if(link_class!='new' and link_label!='edit' and first_part=="/w/ind" or (first_part=="/wiki/" and second_part!="User" and second_part!="Wiki" and second_part!="Help" and second_part!="Imag") )   
          if((Url.find_by_sql("SELECT * FROM urls WHERE url='#{url_string}'")).empty?)
            the_url = Url.new()
            the_url.url = url_string;
            the_url.depth = 2
            the_url.save()
          end
        end
      }
  end

  def get_response()

    # open-uri RDoc: http://stdlib.rubyonrails.org/libdoc/open-uri/rdoc/index.html
    open("http://en.wikipedia.org#{@url.url}", 
        "User-Agent" => "Mozilla/5.0 (Macintosh; U; Intel Mac OS X; da; rv:1.8.1.16) Gecko/20080702 Firefox/2.0.0.16") { |f|
        # Save the response body
        #puts f.read
        f.read
        
    }
  end

end