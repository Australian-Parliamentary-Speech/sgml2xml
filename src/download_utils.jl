using HTTP

function get_response(url)
    # Parse and properly encode the URL to handle spaces and special characters
    encoded_url = replace(url, r" +" => "") 
    response = HTTP.get(encoded_url, ["User-Agent" => "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36"])
    return response
end

