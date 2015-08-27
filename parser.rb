class Parser

  $settings  = {}
  $data      = []
  $loc       = { :x => 0, :y => 0 }
  $variables = {}
  $top       = []

  def move
    # Moving to the right
    $loc[:x] += 1

    # Checking bounds
    if $loc[:x] >= $data[$loc[:y]].length
      $loc[:y] += 1
      $loc[:x] = 0
    end

    if $loc[:y] == $data.length
      # We're at the end of the data
      puts "EOF" if $settings[:debug]
      return false
    end

    return true
  end

  def initialize settings, data
    $settings=settings
    $data=data

    # General settings
    $settings[:escape]       = false
    $settings[:assign]       = false
    $settings[:convert]      = false
    # $settings[:debug]        = true

    # String settings
    $settings[:is_string]    = false

    # Number settings
    $settings[:is_number]    = false
    $settings[:base]         = 10
  end

  def run
    # Parser loop :D
    loop do

      char=$data[$loc[:y]][$loc[:x]]

      if char == 0 || ( char == ' ' && ! ( $settings[:escape] || $settings[:is_string] || $settings[:is_number] ) )
        # Just ignore
        break if ! move
        next
      end

      puts "#{char}" if $settings[:debug]

      if ! ( char=~/[0-9a-f]/ )
        $settings[:is_number]=false
      end


      ## Parsing ##

      ### !!! Most important functions here !!! ###
      if char=='\\' && ( ! $settings[:escape] )
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

      # If we're dealing with a string
      elsif $settings[:is_string]
        $settings[:escape]=false

        $top[-1]+=char

      ### !!! Other commands below here !!! ###

      # Enable conversion
      elsif char=='~' && ( ! $settings[:escape] )
        $settings[:convert]=true

      # Check if variable
      elsif $variables[:"#{char}"] != nil && ( ! $settings[:escape] )
        $settings[:escape]=false

        # Push variable to stack
        $top.push $variables[:"#{char}"]

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
            $settings[:base]=10
            $top.push char.to_i $settings[:base]
          end
        end

      elsif char==':'  && ( ! $settings[:escape] )
        $settings[:assign]=true

      elsif $settings[:assign] && ( $top != nil )
        $settings[:escape]=false

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
        z=nil

        # Errors when adding Strings to Fixnums
        if ! ( x.is_a?(Fixnum) && y.is_a?(Fixnum) )
          x=x.to_s
          y=y.to_s
        end

        # eval() allows injection here!
        # $top.push eval("#{x}#{char}#{y}")

           if char=='+'   then z=x+y
        elsif char=='-'   then z=x-y
        elsif char=='*'   then z=x*y
        elsif char=='/'   then z=x/y
          end

      $top.push z

      # Exit the program
      elsif char==';'  && ( ! $settings[:escape] )
        # Exit program
        break

      end # char == ...


      # Outputting settings for debug
      puts "\t#{$variables}\t\t#{$top}\n\t#{$settings}" if($settings[:debug])

      break if ! move

    end # loop do
  end # def run
end # class Parser
