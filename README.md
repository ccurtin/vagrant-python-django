# Vagrant-Python-Django VM

A Vagrantfile utilizing Ubuntu 14.04/Trusty to get you started with self-contained Python/Django projects quickly via VirtualEnv.
Create contained environments within the VM via `. init_python_project [PROJECT_NAME] [PYTHON_VER] [DJANGO_VER]`

## Installation
  - install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)(_recommended_) or VMWare for [MAC](https://my.vmware.com/web/vmware/info?slug=desktop_end_user_computing/vmware_fusion/8_0), [Windows](http://www.vmware.com/products/workstation.html) or [Linux](http://www.vmware.com/products/workstation-for-linux.html) on your host machine.
  - install [Vagrant](https://www.vagrantup.com/downloads.html) on your host machine.
  - edit `config.yml` to setup network, CPU and folder sync configurations.
  - run `vagrant up` to setup the VM.

## Usage

  - login to machine `vagarnt ssh` and run `sudo su` for privileged commands. (virtualenvwrapper will create necessary files in the root sync folder )
  - make sure you are in the synced_folder directory before running the command below. Default directory here is: `/vagrant/www/`
  - run the command `. init_python_project [PROJECT_NAME] [PYTHON_VERSION] [DJANGO_VERSION]` to create a new Python Environment so projects/packages are contained. **All python environments will be initialized in the synced_folder (`/vagrant/www/` by default). Notice the preceding period. This will automatically cd into the project directory after setup.**
  - VirtualEnv is _not_ a VM container, it is simply to create self-contained python environments. Think of it as a sandbox, not a full fledged VM. Plus, we already have the VM!
  - Run `python -V` and `django-admin --version` to make sure everything checked out.
  - run `deactivate` to exit virtualenv environment or `workon [PROJECT_NAME]` to activate it. Alternatively, just navigate to the project folder to activate the environment.
  - do not change project folder names, as it may cause issues.
  - when you run the server in Django via `python manage.py runserver [::]:80`, note that you may now access the Django project on your Host Machine via the `hostname` entered in your config file.
  - the PS1 prompt is set up to let you know which virtualenv you are working with and what branch you are actively on.
  - although these projects are contained in the webserver's root(for folder sync reasons), do not upload any of your Python files into the web document root in production environments, for security's sake.

## Useful Commands
#### General VM CPU Info
  - view CPU firmware and memory: `sudo lshw -class memory`
  - view CPU info: `lscpu`
  - check current OS info: `lsb_release -a`

#### Start a Django Project
  - start a django project: `django-admin startproject [PROJECT_NAME]`
  - start a django app for the project: `python manage.py startapp [APP_NAME]`
  - start django server: `python manage.py runserver [::]:80` or `startserver`

#### Sharing the Project
  - navigate to a project folder so that it is active.
  - run `pip freeze > requirements.txt` to export a list of installed packages for the environment, _including_ the VM packages.
  - if you'd to only export the _local_ packages within the virtualenv environment, use the `-l` flag. `pip freeze -l > requirements.txt`
  - to install these packages within a different environment: `pip install -r requirements.txt`
  - run `vagrant share` on the HOST machine to share your project(s) with the world. For development and Q/A only. Be careful with sensitive data before proceeding. You can even use your own domain to share projects: http://projectname.yourwebsite.com

## Issues
  - Be sure that Python and Django versions are compatible together when installing both at the same time.

Please [open an issue](https://github.com/ccurtin/vagrant-python-django/issues/new) for support.

## Contributing

Please contribute using [Github Flow](https://guides.github.com/introduction/flow/). Create a branch, add commits, and [open a pull request](https://github.com/ccurtin/vagrant-python-django/compare/).
