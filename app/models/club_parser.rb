class ClubParser < Parser

  def initialize(doc, infobox_table, url)
    
    club = parse_club_infobox(infobox_table)

    if(club.full_name)
      club.name = find_club_name(infobox_table)
      if(club.name.nil? or club.name=="")
        club.name = club.full_name
      end
      club.crest_url = find_club_crest(infobox_table)
      
      club_url = ClubUrl.new
      club_url.url = url
      #club.url = url
      
      saved_club = Club.find_by_full_name(club.full_name)
      
      if((saved_club.nil?) or (saved_club.name!=club.name or saved_club.founded!=club.founded))
        club.save
        club_url.club = club
      else
        club_url.club = saved_club
      end
      
      club_url.save

      puts club.to_s
      url.depth = 1
    else
      url.depth = 2
    end

    puts "parsed club: #{club}"

  end

  def parse_club_infobox(infobox_table)
    club = Club.new()

    infobox_table.search("/tr").each do |tr|

      if(tr.at("/th/span/a[@title='Football club names']"))
        club.full_name = parse_club_full_name(tr.search("td"))
        club.name = club.full_name
      elsif(tr.at("/th/a[@title='Stadium']"))
        club.stadium = parse_stadium_cell(tr.search("td"))
      elsif (tr.at("/th/span/a[@title='Lists of nicknames in football (soccer)']"))
        # TODO: parse 
        # Nickname(s): <i>Colorado</i> (<i>The Red</i>)<br />
        # <i>Inter</i><br />
        # <i>Nação Vermelha (</i>Red Nation<i>)<br /></i> O Clube do Povo <i>(</i>The Folk's Club<i>)<br /></i>

        club.nickname = $coder.decode(tr.search("td").inner_html)
      else
        th = tr.at("/th")
        if(th)

          th_name = th.inner_html;
          if(th_name=="Founded")
            parse_foundation_date(tr.at("td"))
          elsif(th_name=="Short name")
            club.name = tr.at("td").inner_html
          elsif(th_name=="Chairman")
            club.chairman = parse_club_chairman_or_manager(tr)
          elsif(th_name=="Manager" or th_name=="Head Coach")
            club.manager = parse_club_chairman_or_manager(tr)
          elsif(th_name=="League")
            league_link = tr.at("td/a")
            if(league_link)
              club.league = league_link.inner_html
            end
          else
            #puts "th: #{th}"
          end
        end
      end
      #puts "tr: #{tr.inner_html}"
    end
    
    return club

  end

  def parse_foundation_date(table_cell)
    links = table_cell.search("a")

    puts "links.length: #{links.length}"

    if(links.length>=2)
      puts "0: #{links[0].inner_html}"
      puts "1: #{links[1].inner_html}"
    elsif (links.length==1)
      puts "0: #{links[0].inner_html}"
    else
      puts "-: #{table_cell.inner_html}"
    end
  end

=begin    
  <td class="" style="">
  <a title="March 6" href="/wiki/March_6">6 March</a>
  <a title="1902" href="/wiki/1902">1902</a>
  <br/>
  (as
  <i>Madrid Football Club</i>
  )
  <sup id="cite_ref-Real_Madrid_turns_106_.28I.29_2-0" class="reference">
  <a title="" href="#cite_note-Real_Madrid_turns_106_.28I.29-2">[3]</a>
  </sup>
  </td>
=end

  def find_club_crest(infobox_table)

    #puts infobox_table
    cell = infobox_table.at("/tr/td")
    
    crest_image = cell.at("/a[@title='logo']/img[@alt='logo']")
    if(!crest_image)
      crest_image = cell.at("/a/img")
    end

    if(!crest_image)
      crest_image = cell.at("/div/a/img")
    end

    if(!crest_image)
      crest_image = cell.at("/div/div/span/a/img")
    end

    if(crest_image)
      return crest_image.attributes['src']
    else 
      puts "Could not find ClubCrest: #{cell.inner_html}"
    end
  end

  def find_club_name(infobox_table)
    name_cell = infobox_table.search("/caption[@class='fn org']")
    return name_cell.inner_html
  end

  def parse_club_full_name(club_name_cell)

    break_tag = club_name_cell.search("br")
    if(break_tag)
      break_tag.remove
    end

    span_tag = club_name_cell.search("span")
    if(span_tag)
      span_tag.remove
    end

    sup_tag = club_name_cell.search("sup")
    if(sup_tag)
      sup_tag.remove
    end

    return $coder.decode(club_name_cell.inner_html)
  end

  def parse_stadium_cell(stadium_cell)
=begin
    <a href="/wiki/Vejle_Stadion" title="Vejle Stadion">Vejle Stadion</a>, <a href="/wiki/Vejle" title="Vejle">Vejle</a><br />
    (<a href="/wiki/List_of_football_(soccer)_stadiums_by_capacity" class="mw-redirect" title="List of football (soccer) stadiums by capacity">Capacity</a>: 10,250)
=end
    stadium = stadium_cell.inner_html

    stadium_link = stadium_cell.at("a")
    if(stadium_link)
      stadium = stadium_link.inner_html
    end
    return stadium
  end

  def parse_club_chairman_or_manager(tr)
    table_cell_link = tr.at("td/a")
    if(table_cell_link)
      chairman = table_cell_link.inner_html
    elsif
      table_cell = tr.at("td")
      if(table_cell)

        span_tag = table_cell.at("span")
        if(span_tag)
          span_tag.swap("")
        end

        chairman = table_cell.inner_html.strip
      end
    end

    if(chairman)
      return chairman
    end
  end
end