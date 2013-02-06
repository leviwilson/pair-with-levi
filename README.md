# Remote Pairing Sessions via [EC2](http://aws.amazon.com/ec2/)
This repo is a collection of shell scripts and public keys that I use to create ad-hoc remote pairing sessions using [Amazon EC2](http://aws.amazon.com/ec2/), [tmux](http://tmux.sourceforge.net/) and the terminal.

## Creating the EC2 Instance
Creating the EC2 instance is simple.  Just go to your [EC2 console](https://console.aws.amazon.com/ec2/home) and launch a new instance.  Since we'll only be using the EC2 instance for SSH tunneling, a micro instance.  I use the Ubuntu Server 12.04.1 LTS instance. Note the key pair that you use for the login.

### After Creation
After the EC2 instance has been created, we'll need to ssh into it.  Noting the key pair you used to create the instance, use the following command to ssh to it:

```
ssh -R1337:localhost:22 -i [your key pair].pem ubuntu@[you EC2 dns instance]
```

This tells the EC2 instance to create a local port that maps back to port 22 on _your_ local machine.  We will use this later.

Here is an example output:

```
ssh -R1337:localhost:22 -i levis_pair.pem ubuntu@ec2-54-234-132-142.compute-1.amazonaws.com
The authenticity of host 'ec2-54-234-132-142.compute-1.amazonaws.com (54.234.132.142)' can't be established.
RSA key fingerprint is 7b:2b:d2:bd:6a:66:02:1f:08:5c:4f:4d:22:71:5d:bf.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'ec2-54-234-132-142.compute-1.amazonaws.com,54.234.132.142' (RSA) to the list of known hosts.Welcome to Ubuntu 12.04.1 LTS (GNU/Linux 3.2.0-31-virtual x86_64)

 * Documentation:  https://help.ubuntu.com/
  System information as of Sun Feb  3 20:08:18 UTC 2013
  System load:  0.04             Processes:           58  Usage of /:   9.6% of 7.87GB   Users logged in:     0  Memory usage: 6%               IP address for eth0: 10.193.39.148  Swap usage:   0%
  Graph this data and manage this system at https://landscape.canonical.com/0 packages can be updated.
0 updates are security updates.
Get cloud support with Ubuntu Advantage Cloud Guest
  http://www.ubuntu.com/business/services/cloud

The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

ubuntu@domU-12-31-39-0F-24-66:~$ 
```

### Creating the `pair` Account
Next we need to create an account for your pair to remote into. To do this, run the [`levis_pair_user_setup.sh`](https://github.com/leviwilson/pair-with-levi/blob/master/levis_pair_user_setup.sh).  Create a password and accept the defaults.  Here is a sample output.

```
ubuntu@domU-12-31-39-0F-24-66:~/pair-with-levi$ sudo sh levis_pair_user_setup.sh 
Adding user `pair' ...
Adding new group `pair' (1001) ...Adding new user `pair' (1001) with group `pair' ...Creating home directory `/home/pair' ...Copying files from `/etc/skel' ...Enter new UNIX password: Retype new UNIX password: 
passwd: password updated successfullyChanging the user information for pairEnter the new value, or press ENTER for the default
        Full Name []: 
        Room Number []:         Work Phone []: 
        Home Phone []: 
        Other []: 
Is the information correct? [Y/n] Y
pair@domU-12-31-39-0F-24-66:/home/ubuntu/pair-with-levi$ 
```

### Setting up SSH for the `pair` User
Next we need to setup the `pair` user to be able to ssh into the EC2 instance.  Do do so, switch to the `pair` user (with the password you created above) and run the [`levis_pair.sh`](https://github.com/leviwilson/pair-with-levi/blob/master/levis_pair.sh) script.

```
su pair
Password:
sh levis_pair.sh
```

After this your pair should be able to ssh into the EC2 instance.  If you look in [`levis_pair_authorized_keys`](https://github.com/leviwilson/levis_pair_authorized_keys) you will see that the `pair` user's key has been setup so that when your pair connects to EC2 using the [`levis_pair_rsa`](https://github.com/leviwilson/pair-with-levi/blob/master/levis_pair_rsa) key, they will automatically be ssh'ing  back to your local machine that you originally connected to EC2 with.  All that is left now is to setup your local machine for your pair's connection.

## Setting Up Your Local Machine
All that is left to do is to setup your local machine to be able to accept the ssh tunneled connection from EC2 to your local machine.  This is where the magic happens for tmux.  Open up your `~/.ssh/authorized_keys`.  We will need to set it up so your machine can accept the [`levis_pair_rsa.pub`](https://github.com/leviwilson/pair-with-levi/blob/master/levis_pair_rsa.pub) key.  Your `authorized_keys` should look like the following:

```
command="tmux attach",no-port-forwarding,no-X11-forwarding,no-agent-forwarding ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDSz/TTS3+aFV5vwDpTL0Sc9UiZaAerSM+7UWI4oMvCgZE/DuTkzc77pVlT03nNKGzQYU8UVWawvsWsDr3i2kGjko/5YFQDOOvB0GRz00rRYOVeC4pKRef6LBgxZwnIwbIbPvboxmjLRTs92HEiB2UEraAw4TLkEYoH+nLh8sQ6AXA+M18GlBlpfNO/2a49cpC0h1x7ekxmnI4JAqrK53uDtLKN660nqhFPnmLNO99EWvqs2TaI9f1EgvbxlPmUiSWPSWyP5XmHGSw0G4m4uOdifhkH3zCb/z5bvDRsIkfTIi/cB9E3mcGzTcpNhQaGoOzIgbZvnzy/BB/v2BtI2n6F levis_pair@leviwilson.com
```

This tells our local machine to accept the public key, and when they connect to automatically launch the `tmux attach` command.  Note that you will have to have an existing `tmux` session open already for them to be able to connect, otherwise they will be booted immediately.

### `authorized_keys` Security
One other thing that you may need to do is to `chmod 600 ~/.ssh/authorized_keys`.  This sets the security on `authorized_keys` so that your user, and only your user will be able to access this file.

## Try It Out
Since you are already connected to the EC2 instance and have a `tmux` session open, all your pair needs to do is to download the `levis_pair_rsa` file, `chmod 600` it and then ssh with it.  The following commands should work.

```
curl https://github.com/leviwilson/pair-with-levi/blob/master/levis_pair_rsa
chmod 600 levis_pair_rsa
ssh -i levis_pair_rsa pair@[your ec2 instance]
```

## Props
Credit where credit is due, [Zee Spencer](http://twitter.com/zspencer) is the one who originaly set all of this up.  This `README` has only been adapted to use with ad-hoc EC2 instances.
