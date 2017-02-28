 #!/bin/bash         
 # say hello
 echo Hello World

# copy config files into place
sudo cp default /etc/ngnix/sites-available/default/
sudo cp vc.successops.com /etc/ngnix/sites-available/vc.successops.com/