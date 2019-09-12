package com.srk.lambda;

import com.amazonaws.serverless.exceptions.ContainerInitializationException;
import com.amazonaws.serverless.proxy.internal.LambdaContainerHandler;
import com.amazonaws.serverless.proxy.model.AwsProxyRequest;
import com.amazonaws.serverless.proxy.model.AwsProxyResponse;
import com.amazonaws.serverless.proxy.spring.SpringBootLambdaContainerHandler;
import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestStreamHandler;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.commons.io.IOUtils;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

public class Handler implements RequestStreamHandler {

    public static final SpringBootLambdaContainerHandler<AwsProxyRequest, AwsProxyResponse> handler;

    static {
        try {
            handler = SpringBootLambdaContainerHandler.getAwsProxyHandler(TourLambdaApplication.class);
        } catch (ContainerInitializationException e) {
            // if we fail here. We re-throw the exception to force another cold start
            String errMsg = "Could not initialize Spring Boot application";
            //logger.error(errMsg);
            throw new RuntimeException("Could not initialize Spring Boot application", e);
        }
    }


    @Override
    public void handleRequest(InputStream inputStream, OutputStream outputStream, Context context) throws IOException {
        try {
            System.out.println(context.getClientContext().getCustom());
            System.out.println(context.getFunctionName());

        } catch (Exception ex) {
            ex.printStackTrace();
        }

     //   ObjectMapper mapper = LambdaContainerHandler.getObjectMapper();
    //    mapper.readValue()

       // String request = IOUtils..toString(inputStream);
     //   System.out.println("Request:" + request);

        handler.proxyStream(inputStream, outputStream, context);
        // just in case it wasn't closed
        outputStream.close();
    }

//    SpringLambdaContainerHandler<AwsProxyRequest, AwsProxyResponse> handler;
//    boolean isinitialized = false;
//
//    public AwsProxyResponse handleRequest(AwsProxyRequest awsProxyRequest, Context context) {
//        if (!isinitialized) {
//            isinitialized = true;
//            try {
//                XmlWebApplicationContext wc = new XmlWebApplicationContext();
//                wc.setConfigLocation("classpath:/applicationContext.xml");
//                handler = SpringLambdaContainerHandler.getAwsProxyHandler(wc);
//            } catch (ContainerInitializationException e) {
//                e.printStackTrace();
//                return null;
//            }
//        }
//        AwsProxyResponse res = handler.proxy(awsProxyRequest, context);
//        return res;
//    }
}
