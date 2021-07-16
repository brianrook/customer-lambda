package com.bullyrooks.customerlambda.function;


import com.bullyrooks.customerlambda.service.HelloWorldService;
import com.bullyrooks.customerlambda.service.dto.HelloWorldRequest;
import com.bullyrooks.customerlambda.service.dto.HelloWorldResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.function.Function;

@Component
public class HelloWorldFunction implements Function<HelloWorldRequest, HelloWorldResponse> {

    @Autowired
    HelloWorldService helloWorldService;

    @Override
    public HelloWorldResponse apply(HelloWorldRequest input) {
        return helloWorldService.getHelloWorldResponse(input);
    }
}
