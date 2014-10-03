package edu.mit.simile.rdfizer.oai;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.StringReader;
import java.net.URL;
import java.text.DateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.List;

import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.PosixParser;
import org.apache.commons.codec.digest.DigestUtils;
import org.apache.commons.digester.Digester;
import org.apache.log4j.Logger;
import org.apache.log4j.PropertyConfigurator;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

import ORG.oclc.oai.harvester2.verb.ListMetadataFormats;
import ORG.oclc.oai.harvester2.verb.ListRecords;

/**
 * @author Stefano Mazzocchi
 */

public class Main {

    static Logger logger;
    
    static final int DEFAULT_SLOT_SIZE = 1000;
    static final String TRANSFORMERS = "transformers";
    
    public static void main(String args[]) {
        new Main().process(args);
    }

    public static void fatal(String msg) {
        System.err.println(msg);
        System.exit(1);
    }

    public static void fatal(String msg, Exception e) {
        System.err.println(msg + ": " + e.getMessage());
        e.printStackTrace(System.err);
        System.exit(1);
    }
    
    Transformers transformers;
    
    public void process(String[] args) {

        boolean dump = false;
        String url_str = null;
        String extension = null;
        String prefix = null;
        String fromDate = null;
        String untilDate = null;
        String set = null;
        String initialResumptionToken = null;
        
        List schemas = null;
        URL url = null;
        File output = null;
        File transformersFolder = new File(TRANSFORMERS);

        Logger.getRootLogger().removeAllAppenders();
        PropertyConfigurator.configure(getClass().getResource("/log4j.properties"));
        logger = Logger.getLogger(Main.class);
        
        CommandLineParser parser = new PosixParser();

        Options options = new Options();
        options.addOption( "h", "help", false, "show this help screen" );
        options.addOption( "d", "dump", false, "do not apply the RDF transformation, dump the OAI results as they are" );
        options.addOption( "t", "transformers <folder>", true, "the folder that contains the xslt transformers (default: " + TRANSFORMERS + ")" );
        options.addOption( "m", "metadata-schema <prefix>", true, "process only the specified metadata schema (by default all schemas are processed)" );
        options.addOption( "f", "from <date>", true, "the starting date formatted as YYYY-MM-DD (by default all records are harvested)" );
        options.addOption( "u", "until <date>", true, "the ending date formatted as YYYY-MM-DD (by default all records up to the present are harvested)" );
        options.addOption( "s", "set <name>", true, "request only metadata from the specified set (should be a set as returned by the ListSets OAI verb)" );
        options.addOption( "r", "resume <token>", true, "resume a previous download, starting at a given resumption token (options 'from', 'until' and 'set' will be discarded, and you must set 'metadata-schema' correctly)" );
        
        try {
            CommandLine line = parser.parse(options, args);
            String[] clean_args = line.getArgs();
                        
            if (line.hasOption("t")) {
                transformersFolder = new File(line.getOptionValue("t"));
                logger.debug("Transformers folder set to: " + transformersFolder);
            }

            if (line.hasOption("m")) {
                prefix = line.getOptionValue("m");
            }
            
            if (line.hasOption("f")) {
                fromDate = line.getOptionValue("f");
                logger.debug("Harvesting records from: " + fromDate);
            }
            
            if (line.hasOption("u")) {
                untilDate = line.getOptionValue("u");
                logger.debug("Harvesting records until: " + untilDate);
            }

            if (line.hasOption("s")) {
                set = line.getOptionValue("s");
                logger.debug("Harvesting records from set: " + set);
            }
        
            if (line.hasOption("r")) {
                initialResumptionToken = line.getOptionValue("r");
                logger.debug("Resuming from token: " + initialResumptionToken);
            }
        
            
            dump = line.hasOption("d");
            extension = (dump) ? "xml" : "rdf";
            if (dump) logger.debug("Dump only (do not transform the OAI results)");

            transformers = new Transformers(transformersFolder);
            
            if (line.hasOption("help") || clean_args.length < 2) {
                HelpFormatter formatter = new HelpFormatter();
                formatter.printHelp("oai2rdf [options] URL output_folder", options);
                System.exit(1);
            }
            
            url_str = clean_args[0];
            url = new URL(url_str);

            output = new File(clean_args[1]);
            if (!output.exists()) output.mkdirs();
            if (!output.isDirectory()) fatal("Output file '" + output + "' is a file, I can only write output to a folder.");
            if (!output.canWrite()) fatal("You don't have permission to write to the output folder '" + output + "'.");
        } catch (Exception e) {
            fatal("Error found initializing", e);
        }		

        // ------------------------------------------------------------

        int total = 0;
        
        try {
            logger.info("Calling ListMetadataFormats on " + url_str);
            ListMetadataFormats metadata = new ListMetadataFormats(url_str);

            Digester digester = new Digester();
            digester.setValidating(false);
            digester.addObjectCreate("OAI-PMH/ListMetadataFormats", ArrayList.class);
            digester.addObjectCreate("OAI-PMH/ListMetadataFormats/metadataFormat", Schema.class);
            digester.addBeanPropertySetter("OAI-PMH/ListMetadataFormats/metadataFormat/metadataPrefix", "prefix");
            digester.addBeanPropertySetter("OAI-PMH/ListMetadataFormats/metadataFormat/schema", "schema");
            digester.addBeanPropertySetter("OAI-PMH/ListMetadataFormats/metadataFormat/metadataNamespace", "namespace");
            digester.addSetNext("OAI-PMH/ListMetadataFormats/metadataFormat", "add");

            schemas = (List) digester.parse(new StringReader(metadata.toString()));
            logger.info(url_str + " uses " + schemas.size() + " metadata schemas");

            Iterator i = schemas.iterator();
            while (i.hasNext()) {
                Schema schema = (Schema) i.next();

                if ((prefix == null) || schema.prefix.equals(prefix)) {
                    logger.info("Harvesting " + schema.prefix + " [" + schema.namespace + " " + schema.schema + "]");
                    Transformer transformer = (dump) ? transformers.getIdentityTransformer() : transformers.getTransformer(schema.namespace, schema.schema);
                    
                    File base = getBase(output, url, schema.prefix);
                    
                    ListRecords listRecords;
                    
                    String resumptionToken;
                    
                    if((initialResumptionToken != null) && schema.prefix.equals(prefix)) {
                    	resumptionToken = initialResumptionToken;
                    	logger.info("Resuming harvesting from " + resumptionToken);
                    	listRecords = new ListRecords(url_str, resumptionToken);
                    } else {
                    	resumptionToken = "";
                    	listRecords = new ListRecords(url_str, fromDate, untilDate, set, schema.prefix);
                    }
                    File file = getFile(base, resumptionToken, extension, 3);
                    OutputStream outputStream = new BufferedOutputStream(new FileOutputStream(file));
                    StreamResult result = new StreamResult(outputStream);
                    while (listRecords != null) {
                        NodeList errors = listRecords.getErrors();
                        if (errors != null && errors.getLength() > 0) {
                            logger.error("Found errors");
                            int length = errors.getLength();
                            for (int j = 0; j < length; j++) {
                                Node item = errors.item(j);
                                logger.error(item);
                            }
                            fatal("Error record: " + listRecords.toString());
                        }
    
                        //File file = getFile(base, resumptionToken, extension, 3);
                        if (logger.isInfoEnabled()) {
                            NodeList records = listRecords.getNodeList("oai20:OAI-PMH/oai20:ListRecords/oai20:record");
                            int batch = records.getLength();
                            total += batch;
                            logger.info("Harvested Records: batch " + records.getLength() + ", total " + total);
                        }
                        logger.info(((dump) ? "Serializing" : "Transforming") + " records to " + file.getAbsolutePath());
                        Source source = new DOMSource(listRecords.getDocument());
                        //OutputStream outputStream = new BufferedOutputStream(new FileOutputStream(file));
                        //StreamResult result = new StreamResult(outputStream);
                        try {
                        	transformer.transform(source, result);
                        } catch (javax.xml.transform.TransformerException e1) {
                        	logger.warn("Exception while transforming, trying once more.", e1);
                        	outputStream.close();
                        	outputStream = new BufferedOutputStream(new FileOutputStream(file));
                        	result = new StreamResult(outputStream);
                        	try {
                        		transformer.transform(source, result);
                        	} catch (javax.xml.transform.TransformerException e2) {
                        		logger.warn("Exception on second attempt to transform, skipping these records!", e2);
                        	}
                        }
                        //outputStream.close();
                        
                        resumptionToken = listRecords.getResumptionToken();
                        if (resumptionToken == null || resumptionToken.length() == 0) {
                            logger.info("No more resumption token found, end was reached.");
                            listRecords = null;
                        } else {
                            logger.info("Resuming harvesting from " + resumptionToken);
                            try {
                            	listRecords = new ListRecords(url_str, resumptionToken);
                            } catch (IOException e) {
                            	logger.warn("IOException while trying to resume from " + resumptionToken + ", trying again.");
                            	listRecords = new ListRecords(url_str, resumptionToken);
                            } catch (SAXException e) {
                            	logger.warn("SAXException while trying to resume from " + resumptionToken + ", trying again.");
                            	listRecords = new ListRecords(url_str, resumptionToken);
                            }
                        }
                    }
                    outputStream.close();
                } else {
                    logger.info("Skipping " + schema.prefix + " [" + schema.namespace + " " + schema.schema + "]");
                }
            }
         } catch (Exception e) {
            fatal("Error", e);
         }
    }
    
    static File getBase(File base, URL url, String prefix) {
        File  file = new File(base, url.getHost() + File.separator + url.getPath().substring(1).replaceAll("/","_") + File.separator + prefix);
        if (!file.exists()) file.mkdirs();
        return file;
    }

    static File getFile(File base, String token, String extension, int levels) {
        String date = DateFormat.getDateTimeInstance().format(new Date());
        String name = DigestUtils.md5Hex(date + token);
        int name_len = name.length();
        StringBuffer buf = new StringBuffer();
        for (int i = 0 ; i < levels; i++) {
            char c = (name_len > i) ? name.charAt(i) : '0';
            buf.append(c);
            buf.append(File.separatorChar);
        }
        File path = new File(base, buf.toString());
        if (!path.exists()) path.mkdirs();
        return new File(path, name + "." + extension);
    }
    
}
