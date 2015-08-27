class Parser

  $settings  = {}
  $data      = []
  $loc       = { :x => 0, :y => 0 }
  $variables = {}
  $top       = []

  def initialize settings, data
    $settings=settings
    $data=data

    # General settings
    $settings[:escape]       = false
    $settings[:assign]       = false
    $settings[:convert]      = false
    $settings[:debug]        = true

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
          $top.push ""
          $settings[:is_string]=true
        end

      elsif char=='~' && ( ! $settings[:escape] )
        $settings[:convert]=true

      elsif $settings[:is_string]

        if $settings[:escape]
          $settings[:escape]=false
        end

        $top[-1]+=char

      elsif char=~/[0-9a-f BDH]/ && ( ! $settings[:escape] )
        if char == ' '
          $settings[:is_number]=false
        elsif $settings[:is_number]
          $top[-1]*=$settings[:base]
          $top[-1]+=char.to_i $settings[:base]
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
              $top.push 0
            end
          else
            if char.to_i == 0
              $settings[:base]=16
            else
              $settings[:base]=10
            end

            $top.push char.to_i $settings[:base]
          end
        end

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
        if $top[-1].is_a? Fixnum
          puts $top[-1].to_s $settings[:base]
        else
          puts $top[-1]
        end

      elsif char=~/[\+\-\*\/]/
        x=$top[-2]
        y=$top[-1]
        $top.push eval("#{x}#{char}#{y}")

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

      puts "\t#{$settings}: #{$variables} {#{$top}}" if($settings[:debug])

      # Moving to the right
      $loc[:x] += 1

      # Checking bounds
      if $loc[:x] >= $data[$loc[:y]].length
        $loc[:y] += 1
        $loc[:x] = 0
      end

      if $loc[:y] == $data.length
        puts "EOF" if $settings[:debug]
        break
      end



    end # loop do
  end # def run
end # class Parser
