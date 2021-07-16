package com.bullyrooks.customerlambda.function;


import com.bullyrooks.customerlambda.service.HelloWorldService;
import com.bullyrooks.customerlambda.service.dto.HelloWorldRequest;
import com.bullyrooks.customerlambda.service.dto.HelloWorldResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.messaging.Message;
import org.springframework.messaging.support.MessageBuilder;
import org.springframework.stereotype.Component;

import java.util.function.Function;

@Component
@Slf4j
public class HelloWorldAPIFunction implements
        Function<Message<HelloWorldRequest>, Message<HelloWorldResponse>> {
    @Autowired
    HelloWorldService helloWorldService;

    @Override
    public Message<HelloWorldResponse> apply(Message<HelloWorldRequest> input) {
        log.info("input message: {}", input);
        HelloWorldResponse response = helloWorldService.getHelloWorldResponse(input.getPayload());
        log.info("got response: {}", response);
        Message returnMessage = MessageBuilder.withPayload(response)
                .setHeader(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .setHeader("statuscode", HttpStatus.OK.value())
                .build();
        log.info("Returning Message: {}", returnMessage);
        return returnMessage;
    }
}
