

                        +-----------------------------+
                        |       OAI-PMH RDFizer       |
                        +-----------------------------+



  What is this?
  ------------

This is an utility tool to convert the metadata contained in an OAI-PMH 
repository to RDF. 

[If you don't know what either OAI-PMH or RDF are, this tool is unlikely to
be useful for you]



  How do I use it?
  ----------------

You launch the RDfizer from the command line by giving it the URL of content
repository that supports OAI-PMH and the folder to where you want the 
harvested RDF to be dumped and the tools does the rest.

But before you run it, you have to build it.




  How do I build it?
  ------------------
  
This RDFizer requires three things:

 1) a Java Virtual Machine installed on your machine (version 1.4 or greater).
    [type 'java -version' at your shell prompt to know what version you have]
    If you don't have it, go to http://www.java.com and download it.
    
 2) Apache Maven installed (version 2.0 or greater)
    [type 'mvn -version' at your shell prompt to know what version you have]
    If maven is not installed, go to http://maven.apache.org/ and download it.
    Don't panic, the installation is really fast and simple.
    
 3) a network connection (this is because Maven will download the required
    libraries when you build the software)
    
Once you're set (and you have the maven command 'mvn' in your path), 
go to your command shell and type:

  mvn package

this will download the required libraries, compile, package and prepare the
copy the required dependencies in the ./target directory. 
That wasn't that painful, wasn't it?

Now you are ready to launch it, and you can do it by typing

  (unix)  ./oai2rdf.sh [url] [folder]
  (win32) .\oai2rdf.bat [url] [folder]
  
at the command line.




  Hmmm, how can this tool RDFize such a general harvesting protocol?
  ------------------------------------------------------------------
  
Glad you asked.

OAI-PMH (at least since version 2.0) supports repository-specific metadata
schemas. Obviously, the RDFizer cannot know in advance what kind of 
metadata schemas the repository is going to use. 

This tool is designed to let you focus on the 'metadata logic' while taking
care of all the gory technical details of the OAI-PMH protocol.

Basically, the transformation logic is given by pluggable XSLT stylesheets
that are invoked by the tool after the data has been harvested.

This tool ships with the stylesheet required to transform the most common
of these metadata schemas, which should cover most needs. For more
special needs, it is easy to extend it without having to write java code, 
but simply write a new stylesheet that converts the OAI-PMH ListRecords
XML response.



   How do I add the stylesheet for my own metadata schema?
   -------------------------------------------------------
   
If you look into the ./transformers/ directory, you'll find, for example:

  transformers/
    oai-dc/
      transformer.properties
      transformer.xslt
      
If you want to add your own stylesheet, just copy that directory structure
and rename "oai-dc" with an identifier for the metadata schema that you
wish to RDFize and keep the file names (the RDFizer expect those). The name
of the folder has no effect (N.B.: this is *not* the metadata prefix used to
query the OAI-PMH!)

To indicate what metadata schema the stylesheet is capable of transforming, 
you have to write it in the transformer.properties file. As for the example
above:

  schema = http://www.openarchives.org/OAI/2.0/oai_dc.xsd
  namespace = http://www.openarchives.org/OAI/2.0/oai_dc/



    Are you interested in my transformer?
    -------------------------------------
    
Sure thing! Send me an email and I'll put it in, the more the merrier.




Have fun with your new fresh pile-o-data.
  
  
                                  - o -

                                                  Stefano Mazzocchi
                                                <stefanom at mit.edu>

