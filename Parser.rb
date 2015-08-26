class Parser

  $settings  = {}
  $data      = []
  $loc       = { :x => 0, :y => 0 }
  $variables = {}
  $top       = nil

  def initialize settings, data
    $settings=settings
    $data=data

    # General settings
    $settings[:escape]       = false
    $settings[:assign]       = false
    $settings[:convert]      = false

    # String settings
    $settings[:is_string]    = false

    # Number settings
    $settings[:is_number]    = false
    $settings[:base]         = 10
  end

  def run
    char=nil

    loop do


      char=$data[$loc[:y]][$loc[:x]]
      # puts char

      if ! ( char=~/[0-9a-f]/ )
        $settings[:is_number]=false
      end

      if char==0
        # Something went wrong with the file :S

      elsif char=='\\' && ( ! $settings[:escape] )
        $settings[:escape]=true

      elsif char=='"' && ( ! $settings[:escape] )
        if $settings[:is_string]
          # Just disable string parsing :P
          $settings[:is_string]=false
        else
          # Settings things ready to take string
          $top=""
          $settings[:is_string]=true
        end

      elsif char=='~' && ( ! $settings[:escape] )
        $settings[:convert]=true

      elsif char=~/[0-9a-f BDH]/ && ( ! $settings[:escape] )
        if char == ' '
          $settings[:is_number]=false
        elsif $settings[:is_number]
          $top*=$settings[:base]
          $top+=char.to_i $settings[:base]
        else
          $settings[:is_number]=true

          if char=~/[BDH]/
            if char == 'B'
              $settings[:base]=2
            elsif char == 'D'
              $settings[:base]=10
            elsif char == 'H'
              $settings[:base]=16
            end

            if $settings[:convert]
              $settings[:convert]=false
            else
              $top=0
            end
          else
            if char.to_i == 0
              $settings[:base]=16
            else
              $settings[:base]=10
            end

            $top=char.to_i $settings[:base]
          end
        end

      elsif $settings[:is_string]

        if $settings[:escape]
          $settings[:escape]=false
        end

        $top+=char

      elsif char==':'  && ( ! $settings[:escape] )
        $settings[:assign]=true

      elsif $settings[:assign] && ( $top != nil )

        if $settings[:escape]
          $settings[:escape]=false
        end

        $variables[:"#{char}"]=$top
        $settings[:assign]=false
        # $top=nil

      elsif char=='.'  && ( ! $settings[:escape] )
        if $top != nil
          if $top.is_a? Fixnum
            puts $top.to_s $settings[:base]
          else
            puts $top
          end
        else
          puts "NO VALUE TO OUTPUT!"
        end

      elsif char==';'  && ( ! $settings[:escape] )
        # Exit program
        break

      elsif $variables[:"#{char}"] != nil

        if $settings[:escape]
          $settings[:escape]=false
        end

        $top=$variables[:"#{char}"]

      end


      # Outputting settings for debug

      puts "\t#{$settings}: #{$variables} [#{$top}]"

      # Moving to the right
      $loc[:x] += 1

      # Checking bounds
      if $loc[:x] >= $data[$loc[:y]].length
        $loc[:y] += 1
        $loc[:x] = 0
      end

      if $loc[:y] == $data.length
        puts "EOF"
        break
      end



    end # loop do
  end # def run
end # class Parser
