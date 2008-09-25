class PlayerParser < Parser

  attr_reader :doc 
  attr_reader :infobox_table
  attr_reader :url

  def initialize(doc, infobox_table, url)
    @doc = doc
    @infobox_table = infobox_table
    @url = url  
  end

  def parse_player()

    player = parse_player_infobox(@infobox_table)

    if(!player.given_name.nil?)

      player.image_url = find_player_image(@infobox_table)

      player.url = @url
      url.depth = 1
      player.save

      puts player.to_s

    else 
      url.depth = 2
    end

  end

  def fix_player_name(player, infobox_table)
    if(player.given_name.nil?)
      # some player attributes must be set to know that it is a player-page 
      # a few other page types also has infobox_table and therefore name
      if(!(player.birthday.nil? and player.height.nil? and player.birth_country.nil?) )
        player.given_name = player.name
      end
    end
    
    if(player.name.nil?)
      player.name = player.given_name
    end
  end

  def parse_player_place_of_birth(player, tr)
    first_value = tr.search("td[2]/a[1]").inner_html
    second_value = tr.search("td[2]/a[2]").inner_html

    # if only one value is present, this is proberly the country
    if(second_value.nil? or second_value=="")
      player.birth_country = first_value
    else
      player.birth_city = first_value
      player.birth_country = second_value
    end
  end

  def parse_player_infobox(infobox_table)
    player = Player.new()

    infobox_table.search("/tr").each do |tr|

      first_cell = tr.at("/td")

      if(!first_cell)
        first_header_cell = tr.at("/th")
        #puts "first_header_cell: #{first_header_cell}"

      else
        #puts "first_cell: #{first_cell}"

        strong_tag = first_cell.at("/b")
        if(strong_tag)
          tmp_string = strong_tag.inner_html
        end 
          
        tmp_string = $coder.decode(tmp_string)

        if(tmp_string=="")
          #puts "no tr/td/b: #{tr}"
        elsif (tmp_string == "Full name")
          player.given_name = $coder.decode(tr.search("td[2]").inner_html)
        elsif (tmp_string == "Date of birth")
          player.birthday = tr.search("td[2]/span/span[@class=\"bday\"]").inner_html
        elsif (tmp_string == "Place of birth")
          parse_player_place_of_birth(player, tr)
        elsif (tmp_string == "Height")
          height_string = tr.search("td[2]").inner_html
          height_string = $coder.decode(height_string)
          height = parse_height_string(height_string)
          player.height = height

        elsif (tmp_string == "Number")
          number = tr.search("td[2]").inner_html
          player.jersey_number = number

        elsif (tmp_string == "Current club")
          club = ""
          #puts tr.search("td[2]/span/a.title")
          #puts tr.search("td[2]/span/a")
          #puts "CLUB:'" + @club + "'"
        elsif (tmp_string == "Years")
          parse_clubs(player, tr)
        else 
          #puts "tmp_string: '" + tmpString + "'"
          #puts (tr/"td[2]").inner_html

        end
      end
    end
    
    player.name = find_player_name(infobox_table)
    fix_player_name(player, infobox_table)
    return player 

  end

  # parses string like
  # 1998–2000
  # <br/>
  # 2000–2006
  # <br/>
  # 2006–    
  # to two-dimensional integer Array [[1998, 2000], [2000, 2006], [2006, nil]]
  def parse_period_cell(period_info_array, period_string, number_of_clubs)

      c = 0
      while(c!=number_of_clubs)
        index = period_string.index("<br />")
        if(index)
          tmp_period_string = period_string[0, index]

          period_info_array[c] = parse_contract_period(tmp_period_string)
          period_string = period_string[index+6, period_string.length].strip
        else 
          if(period_string.nil? or period_string=="")
            period_info_array[c] = [nil, nil]
          else
            period_info_array[c] = parse_contract_period(period_string)
          end
        end
        c += 1
      end
  end

  # parses string of type "2001–2006" and return integer Array [2001, 2006]
  # also supports type "2008–" returning integer Array [2008, nil]
  # TODO support type "" returning integer Array [nil, nil]
  # TODO support type "1987" returning integer Array [1987, 1987]
  def parse_contract_period(period_string)
    period_array = parse_contract_period_by_char(period_string, "–") # long dash
    if(period_array[0].nil? or period_array[1].nil?)
      second_period_array = parse_contract_period_by_char(period_string, "-") # short dash/minus - not same as above
      if(!second_period_array[0].nil? and !second_period_array[1].nil?)
        period_array = second_period_array
      end
    end
    return period_array
  end

  def parse_contract_period_by_char(period_string, dash_char)
    
    period_array = Array.new(2)
    period_array[0] = nil
    period_array[1] = nil

    dash_index = period_string.index(dash_char)
    
    if(!dash_index.nil?)
      period_array[0] = period_string[0, dash_index].to_i
      period_array[1] = period_string[dash_index+dash_char.length, period_string.length]

      if(period_array[1]=="")
        period_array[1] = nil
      else
        period_array[1] = period_array[1].to_i
      end
    else
      period_array[0] = period_string.to_i
    end
    
    return period_array
  
  end
  
  def parse_club_cell(club_info_array, links)
    
    c = 0
    links.each do |link|
      url_string = link.attributes['href']

      club_url
      
      current_urls = Url.find_by_sql("SELECT * FROM urls WHERE url='#{url_string}' LIMIT 1")
      if(current_urls.length!=0)
        club_url = current_urls[0]
      else
        club_url = (Url.new :url => url_string, :depth => 3).save
      end

      if(club_url.visited.nil?)
        Parser.new(club_url)
      end
    
      clubs = Club.find_by_sql("SELECT * FROM clubs WHERE url_id=#{club_url.id} LIMIT 1")
      if(clubs.length>0)
        club_info_array[c] = clubs[0]
        c += 1
      end
    end
  end
  
  # parses string of type "32 (7)" and return integer Array [32, 7]
  # also supports type "32 ()" returning integer Array [32, 0]
  def parse_single_stat(stats_string)
    
    stats_array = Array.new(2)
    stats_array[0] = 0
    stats_array[1] = 0
    start_parenthesis_index = stats_string.index("(")

    if(!start_parenthesis_index.nil?)
       
      # puts "#{stats_string}[0, #{start_parenthesis_index-1}]: '#{stats_string[0, start_parenthesis_index-1]}'"
      stats_array[0] = stats_string[0, start_parenthesis_index-1].to_i
       
      end_parenthesis_index = stats_string.index(")")
      if(end_parenthesis_index)
        # puts "#{stats_string}[#{start_parenthesis_index+1}, #{end_parenthesis_index-1-start_parenthesis_index}]: '#{stats_string[start_parenthesis_index+1, end_parenthesis_index-1-start_parenthesis_index]}'"
        stats_array[1] = stats_string[start_parenthesis_index+1, end_parenthesis_index-1-start_parenthesis_index]
      end
       
      if(stats_array[1]=="")
        stats_array[1] = 0
      else
        stats_array[1] = stats_array[1].to_i
      end
    end
    return stats_array
  end

  # parses string like
  # 32 (7)<br />
  # 129 (37)<br />
  # 44 (6)
  # to two-dimensional integer Array [[32, 7], [129, 37], [44, 6]]
  def parse_stats_cell(stats_info_array, stats_cell, number_of_clubs)
    span_tags = stats_cell.search("/span")
    span_tags.remove

    stats_string = stats_cell.inner_html

    #puts "stats_string: #{stats_string}"

    c = 0
    while(c!=number_of_clubs)

      index = stats_string.index("<br />")
      #puts "index: #{index}"

      if(index)
        tmp_stats_string = stats_string[0, index]
      
        # puts "tmp_stats_string: #{tmp_stats_string}"
        stats_info_array[c] = parse_single_stat(tmp_stats_string)
      
        stats_string = stats_string[index+6, stats_string.length].strip
      else
        if(stats_string=="")
          stats_info_array[c] = [0, 0]
        else
          stats_info_array[c] = parse_single_stat(stats_string)
        end
      end
      c += 1

    end
    #puts stats_info_array
  end
  
  def parse_clubs(player, tr)
 
    next_row = tr.next_sibling

    period_cell = next_row.at("/td[1]")
    clubs_cell = next_row.at("/td[2]")
    stats_cell = next_row.at("/td[3]")

    period_info_array = Array.new
    club_info_array = Array.new
    stats_info_array = Array.new
    
    if(clubs_cell)
      parse_club_cell(club_info_array, clubs_cell.search("/a"))
    end

    if(period_cell)
      parse_period_cell(period_info_array, period_cell.inner_html, club_info_array.length)
    end
    
    if(stats_cell)
      parse_stats_cell(stats_info_array, stats_cell, club_info_array.length)
    end

    c = 0
    club_info_array.each do |club| 
    
      contract = Contract.new()
      contract.player = player
      contract.club = club
      contract.contract_type = Contract::ContractTypes[:player]
      contract.start_year = period_info_array[c][0]
      contract.end_year = period_info_array[c][1]
      contract.apperances = stats_info_array[c][0]
      contract.goals = stats_info_array[c][1]
      
      player.contracts[player.contracts.length] = contract
      c += 1
    end
    
    #player.clubs[player.clubs.length] = clubs[0]

    
  end

  def find_player_image(infobox_table)
    image_cell = infobox_table.at("/tr/td/a[@class='image']/img")

    #puts "image_cell: #{image_cell}"
    if(image_cell)
      image_url = image_cell.attributes['src']
      if(image_url!="/wiki/Image:Replace_this_image_male.svg")
        return image_url
      end
    end
  end

  def find_player_name(infobox_table)
    name_cell = infobox_table.search("/tr/td[@class='fn']")
    return name_cell.inner_html
  end

  def parse_height_string(height_string)
    #  1.84 cm
    #  191 cm
    #  1.80 m
    #  1.85 m (6 ft 1 in)
    #  1.89 m (6 ft <span style="white-space:nowrap">2<s style="display:none">+</s><span class="template-frac"><sup>1</sup><big>⁄</big><sub>2</sub></span></span> in)
    #  6 ft 2 in (1.88 m)
    #  1m85
    #  5 ft 10 in (1.78 m)
    #  1.73m (5ft 8½in)

    # NOT Handled
    # inparseble height_string: 1.82 <a href="/wiki/Metre" title="Metre">m</a>

    tmpString = ""

    cm_index = height_string.index("cm")
    if (cm_index)

      #  179cm - ISNT HANDLED
      #  1.84 cm
      #  191 cm

      tmpString = height_string[0, 4]
      #puts "tmpString: #{tmpString}"
      #puts "cm_index: #{cm_index}"
    else
      #  1.80 m
      #  1.85 m (6 ft 1 in)
      #  1.89 m (6 ft <span style="white-space:nowrap">2<s style="display:none">+</s><span class="template-frac"><sup>1</sup><big>⁄</big><sub>2</sub></span></span> in)
      #  6 ft 2 in (1.88 m)
      #  1.84m
      m_index = height_string.index("m")
      if (m_index)
        len = height_string[0, m_index].length
        # puts "len #{len}"
        if(len>=6)
          tmpString = height_string[m_index - 6, 4]
        elsif(len==5)
          tmpString = height_string[m_index - 5, 4]
        elsif(len==4)
          # 1.84m
          tmpString = height_string[m_index - 4, 4]
        elsif(len==1)
          #  1m85
          # puts "height_string: #{height_string}"
          
          tmpString = "#{height_string[0, len]}#{height_string[2,2]}"          
        else
          puts "inparseble height_string: #{height_string} len #{len}"
        end
      else
        puts "inparseble height_string: #{height_string} len #{len}"
      end
    end
    
    dot_index = tmpString.index(".")
    if(dot_index.nil?)
      return tmpString[0, 3]
    else 
      return "#{tmpString[0, 1]}#{tmpString[2,2]}"
    end
  end

end