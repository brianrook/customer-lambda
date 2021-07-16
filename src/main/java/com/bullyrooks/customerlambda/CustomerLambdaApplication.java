package com.bullyrooks.customerlambda;

import com.bullyrooks.customerlambda.function.HelloWorldAPIFunction;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

@SpringBootApplication
public class CustomerLambdaApplication {

    public static void main(String[] args) {
        SpringApplication.run(CustomerLambdaApplication.class, args);
    }

    @Bean
    HelloWorldAPIFunction apiFunction(){
        return new HelloWorldAPIFunction();
    }
}
