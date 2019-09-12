package com.srk.lambda;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.config.annotation.EnableWebMvc;

@EnableWebMvc
@Controller
public class RouteController {
    @RequestMapping({"/"})
    public String showPage() {
        return "HELLO_WORLD";
    }
}
