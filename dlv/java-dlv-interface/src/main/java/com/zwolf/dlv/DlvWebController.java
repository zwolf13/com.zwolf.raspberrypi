package com.zwolf.dlv;

import java.util.List;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class DlvWebController {

    @PostMapping("/dlv")
    public void triggerDlv(List<String> urls) {
        System.out.println(urls.get(0));
    }

}
