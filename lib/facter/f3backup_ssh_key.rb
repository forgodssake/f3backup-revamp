require 'etc'

# First get the home of the backup user.
# Then check if the ssh key is found and create the fact

begin
  pw = Etc.getpwnam('backup')
  homedir = pw.dir

  if File.exists?("#{homedir}/.ssh/id_rsa.pub")
    ssh_pub = IO.read("#{homedir}/.ssh/id_rsa.pub").split(' ')
    Facter.add("f3backup_ssh_key") do
      setcode do
        ssh_pub[1]
      end
    end
  end
rescue
end
