Puppet::Type::newtype(:artifact) do
    @doc = "Download artifacts from nexus"

    ensurable
    newproperty(:owner) do
        desc "owner of the file"
        validate do |value|
            # just try to get the username from the system
            Etc.getpwnam(value)
        end
    end

    newparam(:group) do
        desc "The group of the artifact"
    end

    newparam(:username) do
        defaultto nil
        desc "nexus username"
    end

    newparam(:password) do 
        defaultto nil
        desc "nexus password"
    end

    newparam(:nexus) do 
        desc "The nexus api bause url"
        defaultto 'https://repository.sonatype.org/nexus'
        munge do |value|
            var = value.chomp "/"
            "#{var}/service/local/artifact/maven/redirect?"
        end
    end

    newparam(:repo) do
        desc "nexus repo id"
    end

    newparam(:classifier) do
        desc "classifier of the artifact"
    end

    newparam(:name) do
        desc "Name of the file to be written to the disk"
    end

    newparam(:id) do
        desc "artifact id in nexus"
    end

    newparam(:path) do
        desc "where the file should be downloaded"
    end

    newparam(:version) do 
        desc "versions in nexus"
    end
    
    newparam(:extension) do
        desc "extension in nexus"
    end

    newproperty(:mode) do
        desc "file mode to be saved"
        validate do |value|
            unless value =~ /\d{4}/
                raise ArgumentError "%s is not a validate mode like 0644" % value
            end
        end
    end
end
