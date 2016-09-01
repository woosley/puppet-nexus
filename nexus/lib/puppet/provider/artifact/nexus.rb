require 'fileutils'
require 'tempfile'
require 'net/http'

Puppet::Type.type(:artifact).provide(:nexus) do
    commands :mkdir => 'mkdir',
             :rm    => 'rm',
             :chown => 'chown',
             :chmod => 'chmod'
            
    def get_file_full_path(resource)
        name = resource[:name]
        path = resource[:path]
        extension = resource[:extension]
        version = resource[:version]
        filename = "%s-%s.%s" % [name, version, extension]
        File.join(path, filename)
    end

    def exists?
        name = get_file_full_path(resource)
        is_file = File.file?(name)
        exists = File.exists?(name)
        if !is_file && exists
           raise ArgumentError,  "%s exists but is not a file" % name
        end
        exists
    end

    def download(uri, user, pass)
        Net::HTTP.start(uri.host, uri.port) {|http|
            req = Net::HTTP::Get.new(uri.to_s)
            req.basic_auth user, pass if user && pass
            res = http.request(req)
        
            if res.code == '301' || res.code == '307' || res.code == '308'
                return download(URI.parse(res.header['location']), user, pass)
            elsif res.code == '404'
                raise Puppet::Error, "Target file can not be found at %s" % uri.to_s
            else
                return res
            end
        }
    end

    def download_artifiact(api_base, repo, id, group, version, classifier, extension, username, password, target)
        nexus = api_base
        params = "r=%s&g=%s&a=%s&v=%s&e=%s&c=%s" % [repo, group, id, version, extension, classifier]
        uri = URI("#{nexus}#{params}")
        res = download(uri, username, password) 
        f = Tempfile.new(resource[:name])
        f.write(res.body)
        f.close
        FileUtils.cp(f.path, target)
        f.unlink
    end

    def create
        dest = get_file_full_path(resource)
        download_artifiact(resource[:nexus],
                           resource[:repo],
                           resource[:id],
                           resource[:group],
                           resource[:version],
                           resource[:classifier],
                           resource[:extension],
                           resource[:username],
                           resource[:password],
                           dest)
        change_owner(resource[:owner], dest)
        change_mode(resource[:mode], dest)
    end

    def change_owner(owner, path)
        chown([owner, path])
    end

    def change_mode(mode, path)
        chmod([mode, path])
    end

    def destroy
        rm(['-f', get_file_full_path(resource)])
    end

    def owner
        Etc.getpwuid(File.stat(get_file_full_path(resource)).uid).name
    end

    def owner=(value)
        change_owner(value, get_file_full_path(resource))
    end

    def mode
        File.stat(get_file_full_path(resource)).mode.to_s(8)[-4, 4]
    end
    
    def mode=(value)
        change_mode(value, get_file_full_path(resource))
    end
end
