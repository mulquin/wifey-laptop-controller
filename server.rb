require 'sinatra'

set :bind, '0.0.0.0'
set :port, 9494

get '/' do
    File.read('index.html')
end

get '/volup' do
    IO.popen('pactl -- set-sink-volume 0 +10%')
end

get '/voldown' do
    IO.popen('pactl -- set-sink-volume 0 -10%')
end

def redshift?
    temp_file = '/tmp/redshift_temperature'
    bright_file = '/tmp/redshift_brightness'

    if File.exists?(temp_file) == false
        File.open(temp_file, "w") { |f| f.write "6500" }
    end

    if File.exists?(bright_file) == false
        File.open(bright_file, "w") { |f| f.write "1.0" }
    end

    temp = File.open(temp_file)
    bright = File.open(bright_file)

    output = Hash["temp" => temp.read, "bright" => bright.read]
    return output
end

def change_redshift(bright, temp = 6500)
    IO.popen('redshift -P -o -l 0.5:0.5 -b ' + bright.to_s)

    temp_file = '/tmp/redshift_temperature'
    bright_file = '/tmp/redshift_brightness'

    File.open(temp_file, "w") { |f| f.write temp.to_s }
    File.open(bright_file, "w") { |f| f.write bright.to_s }

end

get '/brightup' do
    current = redshift?
    bright = current["bright"].to_f

    if bright < 1.0
        change_redshift(bright + 0.1)
    end
end

get '/brightdown' do
    current = redshift?
    bright = current["bright"].to_f

    if bright > 0.1
        change_redshift(bright - 0.1)
    end
end

get '/suspend' do
    IO.popen('xfce4-session-logout -s')
end
