package com.zwolf.dlv;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class DlvWebController {

    @PostMapping(path = "/dlv", consumes = "text/plain", produces = "text/plain")
    public void triggerDlv(@RequestBody String urls) throws Exception {
        BufferedWriter writer = new BufferedWriter(new FileWriter("dlv-web.txt"));
        writer.append(urls);
        writer.append(System.lineSeparator());
        writer.close();
    }

}
