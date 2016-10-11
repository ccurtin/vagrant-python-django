# Vagrant-Python-Django VM

Get started with self-contained Python/Django projects quickly. Create contained environments within the VM via `init_python_env` and administer and swap between environments, projects and DBMS quickly and with ease!

**CURRENTLY ONLY SUPPORTS POSTGRESQL for DMBS**

## Installation
#### Prerequisites
  - install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)(_recommended_) or VMWare for [MAC](https://my.vmware.com/web/vmware/info?slug=desktop_end_user_computing/vmware_fusion/8_0), [Windows](http://www.vmware.com/products/workstation.html) or [Linux](http://www.vmware.com/products/workstation-for-linux.html) on your host machine.
  - install [Vagrant](https://www.vagrantup.com/downloads.html) on your host machine.

#### Configure Virtual Machine(VM) Settings
  edit `config.yml` to setup network, CPU and folder-sync configurations.

#### Logging Into Your VM
  - `vagrant up` to setup and initialize the VM. ( only the first time you run `vagrant up` will take long 5-10 mins )
  - After the VM is initialized, run `vagrant ssh`
  - change the current directory to your projects root by typing `cd $WORKON_HOME`

#### Create a Contained Python Environment
  `init_python_env`. Installing Django is optional.

#### Setup PgAdmin Web interface (phpPgAdmin)
`setup_phppgadmin`

#### Setting Up a New Database For A Django Project 
  `manage_django_db`. **Switch to a Django Project Folder before running**. This will create a new user, alter their role, create a new database, and assign them to a DB. If you just want to assign roles and not create new users/DBs, that works too. Running this command will also automatically update the django `settings.py` file for your project. More DBMS will be added in the future.

## Notes to User:
  - Feel free to change up the base-box OS, but note this has only been tested with Ubuntu 14.04/Trusty.
  - The default settings will run Django on port 80
  - To change the port Django runs on just run: `python manage.py runserver [::]:YOUR_NEW_PORT` in a Django project and that port will be accessible via the `hostname` entered in the `config.yml` file.

#### PostgreSQL Notes
- Defaults to latest stable version PostgreSQL
- Apache is required for phpPgAdmin web interface.
- To change the port(s) Apache runs on, run the command `update_apache_ports`

## Usage
  - VirtualEnv is _not_ a VM container, it is simply to create self-contained python environments. Think of it as a sandbox, not a full fledged VM. Plus, we already have the VM!
  - `cd` into the synced_folder and run the command `init_python_env` to create a new Python Environment so projects/packages are contained. **All python environments will be initialized in the synced_folder (`/vagrant/www/` by default).**
  - Be aware that self-contained Python Environments does ***NOT*** mean self-contained Database Environments. Future releases may take this into account through porting.
  - Run `python -V` and `django-admin --version` to make sure everything checked out.
  - run `deactivate` to exit virtualenv environment or `workon [PROJECT_NAME]` to activate it. Alternatively, whenever you navigate into a project folder, the virtual environment will become activated.
  - the PS1 prompt is set up to let you know which virtualenv you are working with and what branch you are actively on when a git repo is there.
  - If you are switching between many Python Environments and/or Django Projects, be absolutely sure that your active environment( which is assigned in the PS1) is the one you want to install packages and modules on.
  - do not change Django Project folder names, as it may cause issues. Python Environments in the root directory may be renamed if needed though.
  - although these projects are placed in the webserver's root(for folder sync reasons), do not upload any of your Python files into the web document root in _production environments_, for security's sake.

## TO DO
##### Smaller To Dos
  - Let user define PostgreSQL port when running `manage_django_db`. Edit `sed` `/etc/postgresql/9.3/main/postgresql.conf` port=5432. Might want to create a sepatate shell file or method, to scan `/etc/postgresql/` for versions and ask which to update... `sed` return change before confirm and restart service.
  - reconfigure `configure_md5_login` in `manage_django_db_postgres` shouldn't be automatically run, only once or manually.
  - don't force any ports for a DBMS'. Let user configure any ports in `config.yml`
    - update PostgreSQL
  - Organize the Installation section in the README for each individual DBMS. Have a "General Installation" then sub-headings for each DMBS, explaining extensions, commands, configurations, etc.
  
##### Bigger To Dos
  - create a utility that installs necessary dependencies to run gulp/grunt tasks for Django Projects.
    - also create task-runner templates for projects... `init_taskrunner` >>> `gulp`...running. Maybe best to package it all up into one command so no separate install takes place; just run prior checks when `init_taskrunner` or similar. Setup BrowserSync, PostCSS, Autoprefixer, SourceMaps, Uglify, etc.  

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

  Please [open an issue](https://github.com/ccurtin/vagrant-python-django/issues/new) for support.

## Contributing

Please contribute using [Github Flow](https://guides.github.com/introduction/flow/). Create a branch, add commits, and [open a pull request](https://github.com/ccurtin/vagrant-python-django/compare/).
