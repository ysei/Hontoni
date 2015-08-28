require './parser.rb'


# Main function
def main args

  $settings = {
    :file => nil,
    :debug => false
  }

  i=0
  while i < args.length
    arg=args[i]

    # File
    if arg == "-f" || arg == "--file"
      $settings[:file] = args[i+=1]
    elsif arg == "-d" || arg == "--debug"
      $settings[:debug]=true
    end

    i+=1
  end

  if $settings[:file] == nil
    puts "No file specified! Use -f <filename> or --file <filename> !"
    return
  end

  data1D = File.read $settings[:file]
  data2D = data1D.split "\n"
  data3D = []

  data2D.each.with_index do |data, ix|
    data3D[ix] = data.split ''
  end

  return (Parser.new $settings, data3D).run
end

# Run main
exit main ARGV
