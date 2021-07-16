package com.bullyrooks.customerlambda.service;

import com.bullyrooks.customerlambda.service.dto.HelloWorldRequest;
import com.bullyrooks.customerlambda.service.dto.HelloWorldResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

@Component
@Slf4j
public class HelloWorldService {

    public HelloWorldResponse getHelloWorldResponse(HelloWorldRequest input) {
        log.info("Inside getHelloWorldResponse: {}", input);
        return HelloWorldResponse.builder()
                .response(
                        getStringResponse(input.getName()))
                .build();

    }

    public String getStringResponse(String input){
        log.info("Inside getStringResponse: {}", input);
        return new StringBuilder("Hello, ")
                .append(input)
                .toString();
    }
}
