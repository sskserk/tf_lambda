package com.srk.lambda;


import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.config.annotation.EnableWebMvc;

@RestController
@EnableWebMvc
public class RouteController {

    @RequestMapping(path = "/ping", method = RequestMethod.GET)
    public String showPage() {
        return "HELLO_WORLD";
    }

    @RequestMapping(path = "/", method = RequestMethod.GET)
    public String root() {
        return "ROOT";
    }
}
