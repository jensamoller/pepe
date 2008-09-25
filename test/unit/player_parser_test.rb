require 'test_helper'
require 'hpricot'
class PlayerParserTest < ActiveSupport::TestCase

  def setup
    @player_parser = PlayerParser.new(@doc, @infobox_table, @url)
  end

  # parses string of type "32 (7)" and return integer Array [32, 7]
  # also supports type "32 ()" returning integer Array [32, 0]
  def test_parse_single_stat
    
    inputs = ["32 (7)", "32 ()", ""]
    expected_results = [[32, 7], [32, 0], [0, 0]]

    c = 0
    inputs.each do |input|
      actual_result =  @player_parser.parse_single_stat(input)
      #puts "input: #{input}"
      #puts "-- expected result --- "
      #puts expected_result
      #puts "-- -------------- --- "

      #puts "-- actual_result --- "
      #puts actual_result
      #puts "-- -------------- --- "
      assert actual_result == expected_results[c]
      c += 1
    end
  end
  
  
  def test_parse_stats_cell()
    
    inputs = [
      "<td>32 (7)<br />32 ()<br />0 (0)</td>", 
      "<td>32 (7)<br />0 (0)</td>"]
    expected_results = [[[32, 7], [32, 0], [0, 0]], [[32, 7], [0, 0], [0, 0]]]
    
    c = 0
    inputs.each do |input|
      
      stats_info_array = Array.new
      doc = Hpricot.parse(input)
    
      stats_cell = doc.search("/td")
    
      @player_parser.parse_stats_cell(stats_info_array, stats_cell, 3)
      
      if(stats_info_array != expected_results[c])
        puts "-- expected result --- "
        puts expected_results[c]
        puts "-- -------------- --- "

        puts "-- actual_result --- "
        puts stats_info_array
        puts "-- ------------- --- "
      end
      assert stats_info_array == expected_results[c]
      c += 1
    end
  end
  
  
  def test_parse_height_string()
    #  1.84 cm
    #  191 cm
    #  1.80 m
    #  1.85 m (6 ft 1 in)
    #  1.89 m (6 ft <span style="white-space:nowrap">2<s style="display:none">+</s><span class="template-frac"><sup>1</sup><big>⁄</big><sub>2</sub></span></span> in)
    #  6 ft 2 in (1.88 m)
    #  1m85

    # NOT Handled
    # inparseble height_string: 1.82 <a href="/wiki/Metre" title="Metre">m</a>
    # inparseble height_string: 5 ft 10 in (1.78 m)
    # inparseble height_string: 1.73m (5ft 8½in)
    
    inputs = ["1.80 cm", 
      "180 cm", 
      "180cm", 
      "1.80 m", 
      "1.80 m (6 ft 1 in)", 
      "1.80 m (6 ft <span style=\"white-space:nowrap\">2<s style=\"display:none\">+</s><span class=\"template-frac\"><sup>1</sup><big>⁄</big><sub>2</sub></span></span> in)",
      "6 ft 2 in (1.80 m)", 
      "1m80", 
      #"1.80 <a href=\"/wiki/Metre\" title=\"Metre\">m</a>", 
      "5 ft 10 in (1.80 m)",
      "1.80m (5ft 8½in)"
      ]
    
    expected_result = "180"
      
    inputs.each do |input|
      output = @player_parser.parse_height_string(input)
      
      if (output!=expected_result)
        puts "input: #{input}"
        puts "output: #{output}"
      end
      assert output==expected_result
    end

  end
  
end
