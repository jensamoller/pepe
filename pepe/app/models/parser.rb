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
    gotten_response = get_response()
    # puts "gotten_response: #{gotten_response}"
    if(gotten_response)
      @doc = Hpricot.parse(gotten_response)

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
            ClubParser.new(@body_content_div, infobox_table, @url).parse_club()
          else 
            if(is_in_football_category())
              if(!infobox_table.empty?)
                PlayerParser.new(@body_content_div, infobox_table, @url).parse_player
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
    
    end
    url.save
  end

  def get_wikipedia_info()
    Hpricot::Elements[@body_content_div.at("/h3[@id='siteSub']")].remove
    Hpricot::Elements[@body_content_div.at("/div[@id='contentSub']")].remove
    @body_content_div.search("/table[@class='metadata plainlinks ambox ambox-content']").remove
    @body_content_div.search("/table[@class='metadata plainlinks ambox ambox-style']").remove
    @body_content_div.search("/table[@class='metadata plainlinks mbox-small']").remove

    @body_content_div.search("/h2/span[@class='editsection']").remove
    @body_content_div.search("/h3/span[@class='editsection']").remove
    Hpricot::Elements[@body_content_div.at("/div[@id='jump-to-nav']")].remove

    Hpricot::Elements[@body_content_div.at("/table[@class='infobox vcard']")].remove

    toccolours = @body_content_div.at("/table[@class='toccolours']")
    if(toccolours)
      Hpricot::Elements[toccolours].remove
    end

    navbox = @body_content_div.at("/table[@class='navbox']")
    if(navbox)
      Hpricot::Elements[navbox].remove
    end

    category_links = @body_content_div.at("/div[@class='catlinks']")
    if(category_links)
      Hpricot::Elements[category_links].remove
    end

    stub = @body_content_div.at("/div[@id='stub']")
    if(stub)
      Hpricot::Elements[stub].remove
    end


    return @body_content_div.to_html
  end


  def is_in_football_category()
    output = false
    categories_div = @body_content_div.at("/div[@id='catlinks']")
    if(categories_div)
      output = categories_div.inner_html.include?("football")
      #puts "is_in_football_category: #{output}"
    end
    return output
  end

  def is_valid_link(link)
    url_string = link['href']
    link_class = link['class'] 
    link_label = link.inner_html

    first_part = url_string[0, 6]
    second_part = url_string[6, 4]
    
    return (link_class!='new' and link_label!='edit' and first_part=="/w/ind" or (first_part=="/wiki/" and second_part!="User" and second_part!="Wiki" and second_part!="Help" and second_part!="Imag") )   
      
  end

  def find_links()
    
      @body_content_div.search('a[@href]').map { |link| 
      
      #puts "is_valid_link(link): #{is_valid_link(link)}"  
      if(is_valid_link(link))   

        url_string = link['href']
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

  # deletes any break tags in maintag
  # <b>Jens Aage<br />Møller</b>
  # to <b>Jens AageMøller</b>
  def delete_break_tags(main_tag)
    delete_given_tags(main_tag, "br")
  end
  
  def swap_break_tags_for_whitespace(main_tag)
    break_tags = main_tag.search("br")
    break_tags.each do |break_tag|
      break_tag.swap(" ")
    end
  end


  # deletes any footnote tags in maintag
  # <b>Jens Aage Møller<sup><a href="#anchor">1</a></sup> </b>
  # to <b>Jens Aage Møller</b>
  def delete_footnotes_tags(main_tag)
    delete_given_tags(main_tag, "sup")
  end

  # deletes given tags in maintag
  # <b>Jens Aage<br />Møller</b>
  # to <b>Jens AageMøller</b>
  def delete_given_tags(main_tag, tag)

    main_tag.search(tag).remove 
    # BUG: removes everything after tag as well :( 
    # Example:  full club name: http://en.wikipedia.org/wiki/FC_Girondins_de_Bordeaux

  end

  # removes given tag tags in maintag
  # <b>Jens <i>Aage</i> Møller</b>
  # remove ('i')
  # to <b>Jens Aage Møller</b>
  def remove_given_tags(main_tag, tag)
    manipulating_tags = main_tag.search(tag)
    if(manipulating_tags)
      
        manipulating_tags.each do |tag|
          tag.swap(tag.inner_html)
        end
    end
  end

  def remove_text_tags(main_tag)
    manipulating_tags = ["i", "b", "em", "strong"]
    manipulating_tags.each do |tag|
      remove_given_tags(main_tag, tag)
    end
  end

  def get_response()

    #puts @url.url
    # open-uri RDoc: http://stdlib.rubyonrails.org/libdoc/open-uri/rdoc/index.html

    begin
      open("http://en.wikipedia.org#{@url.url}", 
          "User-Agent" => "Mozilla/5.0 (Macintosh; U; Intel Mac OS X; da; rv:1.8.1.16) Gecko/20080702 Firefox/2.0.0.16") { |f|
           #f.each_line {|line| p line}
    
    
           # Save the response body
           # puts f
           f.read
      
       }
    rescue OpenURI::HTTPError => e
      puts "The request is fucked #{e.message}"
    end
  end

end