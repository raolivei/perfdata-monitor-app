loop do
	sleep 5
	
	require "open-uri"
	require 'yaml'

	File.write 'exercise1.yaml', open('http://candidateexercise.s3-website-eu-west-1.amazonaws.com/exercise1.yaml').read
   	x_result = YAML.load_file('exercise1.yaml')
    
    #Set variables with values
    x_webservername = x_result ['machines']['webserver']['name']
    x_webserverkey = x_result ['machines']['webserver']['sshkey']
    x_webservertype = x_result ['machines']['webserver']['type']
    x_webserverami = x_result ['machines']['webserver']['ami']

    x_applicationname = x_result['machines']['applicationserver']['name']
	x_applicationkey= x_result['machines']['applicationserver']['sshkey']
	x_applicationtype = x_result['machines']['applicationserver']['type']
	x_applicationami = x_result['machines']['applicationserver']['ami']

    #Delete existing resource file (if exists)
    def remove_file(file)
        File.delete('aws_resources.tf')
	end

    # Variables to maintain Author and key names
	y_Auth = "Rafael"
	y_WebKeyName = "goat"
	y_AppKeyName = "wolf"

	# Generating first resource - aws_instance
	iResource = 'resource ' + '"aws_instance" "' + x_webservername +'" {'
	iResource = iResource + "\n"
	iResource = iResource +' ami = "'+x_webserverami+'"'
	iResource = iResource + "\n"
	iResource = iResource +' instance_type = "'+x_webservertype +'"'
	iResource = iResource + "\n"
	iResource = iResource +' key_name = "'+y_WebKeyName+'"'
	iResource = iResource + "\n"
	iResource = iResource + ' }'
	iResource = iResource + "\n"
	iResource = iResource + "\n"

	# Generating second resource - aws_instance
	iResource = iResource +  ' resource ' + '"aws_instance" "' + x_applicationname +'" {'
	iResource = iResource + "\n"
	iResource = iResource +' ami = "'+x_applicationami+'"'
	iResource = iResource + "\n"
	iResource = iResource +' instance_type = "'+x_applicationtype +'"'
	iResource = iResource + "\n"
	iResource = iResource +' key_name = "'+y_AppKeyName+'"'
	iResource = iResource + "\n"
	iResource = iResource + ' }'
	iResource = iResource + "\n"
	iResource = iResource + "\n"

	# Generating third resource - aws_key_pair
	iResource = iResource + 'resource ' + '"aws_key_pair" "' +y_Auth+'" {'
	iResource = iResource + "\n"
	iResource = iResource +' key_name = "'+y_WebKeyName+'"'
	iResource = iResource + "\n"
	iResource = iResource +' public_key = "'+x_webserverkey+'"'
	iResource = iResource + "\n"
	iResource = iResource + ' }'
	iResource = iResource + "\n"
	iResource = iResource + "\n"

	# Generating fourth resource - aws_key_pair
	iResource = iResource + 'resource ' + '"aws_key_pair" "' +y_Auth+'" {'
	iResource = iResource + "\n"
	iResource = iResource +' key_name = "'+y_AppKeyName+'"'
	iResource = iResource + "\n"
	iResource = iResource +' public_key = "'+x_applicationkey +'"'
	iResource = iResource + "\n"
	iResource = iResource + ' }'
	iResource = iResource + "\n"
	iResource = iResource + "\n"

    # Write resources to file
    File.open("aws_resources.tf", "w") do |f|
        f.write(iResource)
	end
	
	puts iResource

end
