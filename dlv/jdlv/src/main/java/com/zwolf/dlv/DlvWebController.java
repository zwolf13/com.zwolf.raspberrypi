package com.zwolf.dlv;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.charset.Charset;
import java.text.SimpleDateFormat;
import java.util.Date;

import org.apache.commons.io.IOUtils;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class DlvWebController {
    // TODO Below constant should come from outside
    private static String BASE_PATH = "/home/pi/git/com.zwolf.raspberrypi/dlv";
    private static String WEB_INPUTS_PATH = BASE_PATH + File.separator + "jdlv/web-inputs";
    private static String DLV_CMD = BASE_PATH + File.separator + "dlv.sh";
    private static String VSEARCH_CMD = BASE_PATH + File.separator + "vsearch.sh";
    private static SimpleDateFormat sdf = new SimpleDateFormat("yyyy.MM.dd-HH.mm.ss");

    @PostMapping(path = "/dlv", consumes = "text/plain", produces = "text/plain")
    public void tiggerDlv(@RequestBody String urls, @RequestParam(defaultValue = "false") boolean isYoutube) throws Exception {
        String dateString = sdf.format(new Date());
        String fileName = WEB_INPUTS_PATH + File.separator + dateString + ".txt";
        BufferedWriter writer = new BufferedWriter(new FileWriter(fileName));
        writer.append(urls);
        writer.append(System.lineSeparator());
        writer.close();

        String dlvCommand = DLV_CMD + " -i " + fileName;

        if (isYoutube) {
            dlvCommand = dlvCommand + " -c " + BASE_PATH + File.separator + "cookies.txt";
        }

        System.out.println("EXECUTING: '" + dlvCommand + "'");
        Process process = Runtime.getRuntime().exec(dlvCommand);
    }

    @GetMapping(path = "/status", produces = "text/plain")
    public String getDlvStatus() throws Exception {
        String dlvCommand = DLV_CMD + " -s";
        System.out.println("EXECUTING: '" + dlvCommand + "'");
        Process process = Runtime.getRuntime().exec(dlvCommand);
        String stdout = IOUtils.toString(process.getInputStream(), Charset.defaultCharset());

        return stdout;
    }

    @GetMapping(path = "/search", produces = "text/plain")
    public String search(@RequestParam(required = true) String query) throws Exception {
        String vsearchCmd = VSEARCH_CMD + " " + query;
        System.out.println("EXECUTING: '" + vsearchCmd + "'");
        Process process = Runtime.getRuntime().exec(vsearchCmd);
        String stdout = IOUtils.toString(process.getInputStream(), Charset.defaultCharset());
        String stderr = IOUtils.toString(process.getErrorStream(), Charset.defaultCharset());

        StringBuffer buffer = new StringBuffer();

        if (stdout == null || stdout.equals("")) {
            buffer.append("<No results>");
        } else {
            buffer.append(stdout);
        }

        if (stderr != null && !stderr.equals("")) {
            buffer.append("\n");
            buffer.append("ERRORS");
            buffer.append("\n");
            buffer.append(stderr);
        }

        return buffer.toString();
    }

}
