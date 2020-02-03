ChemRPS (Chemical Registration & Publishing System)
===================================================

Overview
--------

.. image:: docs/images/chemrps_logo_blue.jpg 

**ChemRPS** is a free Docker based system that allows you 
to load and search SDFiles by structure on your corporate website or local computer.

The system comes with a preconfigured RDKit enabled PostgreSQL database, a search engine (API) and 
a preconfigured webserver with register/search web pages including structure editor (Ketcher from EPAM).
It also contains a program that allows you to bulk load SDFiles.

ChemRPS is intended to be used by small or medium sized companies looking for an easy way to make
their chemical structures searchable on the Internet, without the need to invest a lot of money
for license fees or programming services.


Because of the easy deployment ChemRPS can also be used by individuals looking for an 'out-of-the-box'
solution that allows them to make structures contained in SDFiles searchable via Substructure and/or
Structure similarity search.


Docker installation
-------------------

Download and install Docker
Link to 'docker page: <https://docs.docker.com/>'

How to verify that Docker works?

Run simple test program

-Open command prompt (Windows) or terminal (Linux)
-Execute the following command:
 docker run hello-world (Windows)
 or
 sudo docker run hello-world (Linux)

This command downloads a test image and runs it in a container. 
When the container runs, it prints an informational message similar
to the below:

> docker run hello-world

docker : Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
1b930d010525: Pull complete
Digest: sha256:c3b4ada4687bbaa170745b3e4dd8ac3f194ca95b2d0518b417fb47e5879d9b5f
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.
...

After verifying that your docker install worked:

Build/Run ChemRPS
-----------------

Linux:
------

Install git (it is probably already on your system; it is on Ubuntu 18.04 Desktop)
Ubuntu:
 sudo apt-get install git git-core
CentOS:
sudo yum install git

When git installed correctly
Clone the chemrps repository

git clone https://github.com/chemrps-dev/chemrps.git chemrps

Then, change into the newly created directory

cd chemrps/

and run the following command (it is important that you do this from inside the chemrps directory – the “-s” after “sudo” ensures that the current directory is used by “sudo”)

sudo -s ./build

As a first step, this will create all necessary ChemRPS Docker images to your system and may take a while for the initial setup.

After the initial build, you can start the ChemRPS system using

sudo -s ./run

To verify that the system got started correctly type the command:

docker container list

You should get an output similar to the below:

$ docker container list
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                    NAMES
67aba6efe64c        chemrps_web         "nginx -g 'daemon ofâ¦"   12 seconds ago      Up 10 seconds       0.0.0.0:8080->80/tcp     chemrps_web_1
bdcd67be15f3        chemrps_database    "/opt/cpm/bin/uid_poâ¦"   14 seconds ago      Up 12 seconds       0.0.0.0:5432->5432/tcp   chemrps_database_1
5e4f6cd84559        chemrps_php         "docker-php-entrypoiâ¦"   14 seconds ago      Up 12 seconds       9000/tcp                 chemrps_php_1
762cd462d323        chemrps_api         "dotnet chemrpsapi.dâ¦"   14 seconds ago      Up 12 seconds       0.0.0.0:5003->5003/tcp   chemrps_api_1

Windows:
--------

Download chemrps installer files
Open the following github link
https://github.com/chemrps-dev/chemrps
Download repository to your local computer

After the download completed, unpack the archive to a local folder on your host computer

Open a command prompt and navigate to the folder you used unpacking the repository
Execute the following command:

@build

This command creates all necessary images to run the ChemRPS system.

After building the ChemRPS images, you are ready to start the system.

Execute the following command in your command prompt:
@run

You should get an output similar to the below:

.. image:: docs/images/chemrps_picture_1.png



ChemRPS webpages
----------------

If everything went fine and the ChemRPS container are running, you should now be able to  
open the preinstalled ChemRPS search web page using the following link

http://localhost:8080/index.html

You should see a page such as the below:

.. image:: docs/images/chemrps_picture_2.png

After starting the ChemRPS system the first time, there are no data present in the ChemRPS database.
To populate the ChemRPS database with data you can use the preinstalled ChemRPS registration web page using the following link:

http://localhost:8080/registersdfile.html

The preinstalled registration page looks as the below:

.. image:: docs/images/chemrps_picture_3.png

To register a SDFile, click the ‘Browse’ button and navigate to your local SDFile.
Now click the ‘Upload All’ button
You should see a dialog that allows to choose what external fieldname in the uploaded SDFile should be used as ‘COMPOUND_ID’ in the ChemRPS database

Note: COMPOUND_ID must be present in all SDFile records. The value for a given COMPOUND_ID inside the uploaded SDFile must be unique. In addition the value must not be present in the ChemRPS database.
After picking your compound ID field, click the OK button in the field pick dialog.
Now registration  starts and after a while (depending how many records are contained in your SDFile), you should see a result dialog that looks like similar to the below:

.. image:: docs/images/chemrps_picture_4.png

Close the result dialog and click the ‘Open ChemRPS search page’ link to open the search page
You can now do search for the data you registered.

.. image:: docs/images/chemrps_picture_5.png

Stop all ChemRPS container
--------------------------

In order to bring the whole ChemRPS stack down, use the ``down`` script::
Execute the following command from within the chemrps root folder:

@down (Windows) respectively sudo -s ./down (Linux)

Note: Anything you have created and stored so far in the database has been persisted.



Build/Run ChemRPS bulk SDFile loader
------------------------------------

Navigate to the bulksdfileloadconsole folder

cd  bulksdfileloadconsole

Copy the SDFile you want to register to the /sdfile folder

Afterwards edit the config file and specify the SDFile name and the external SDFile fieldname that should be used as COMPOUND_ID during registration

Example:

SDFILENAME=pubchemsample_100records.sdf

COMPOUNDIDFIELDNAME=PubChemCID

Build the image via the command:

@build (Windows) respectively sudo -s ./build (Linux)

Run the console via the command:

@run (Windows) respectively sudo -s ./run (Linux)

Important note:

Every time you register a new SDFile, i.e. place a SDFile inside the ./sdfile folder and edit the config file to specify the SDFile name and the COMPOUND_ID fieldname, you need to rebuild the bulksdfileconsole image by running the build script. 
If you just copy/edit and use the run command the changes you did are ignored.




Bugs, Comments and anything else
--------------------------------

For any questions, bug or problem reports, contact me at my email contact@hjhimmler.de

Hans-Juergen Himmler, 2020-01-27
