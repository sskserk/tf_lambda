package com.srk.lambda;

import com.amazonaws.serverless.exceptions.ContainerInitializationException;
import com.amazonaws.serverless.proxy.internal.model.AwsProxyRequest;
import com.amazonaws.serverless.proxy.internal.model.AwsProxyResponse;
import com.amazonaws.serverless.proxy.spring.SpringLambdaContainerHandler;
import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import org.springframework.web.context.support.XmlWebApplicationContext;

public class Handler implements RequestHandler<AwsProxyRequest, AwsProxyResponse> {
    SpringLambdaContainerHandler<AwsProxyRequest, AwsProxyResponse> handler;
    boolean isinitialized = false;

    public AwsProxyResponse handleRequest(AwsProxyRequest awsProxyRequest, Context context) {
        if (!isinitialized) {
            isinitialized = true;
            try {
                XmlWebApplicationContext wc = new XmlWebApplicationContext();
                wc.setConfigLocation("classpath:/applicationContext.xml");
                handler = SpringLambdaContainerHandler.getAwsProxyHandler(wc);
            } catch (ContainerInitializationException e) {
                e.printStackTrace();
                return null;
            }
        }
        AwsProxyResponse res = handler.proxy(awsProxyRequest, context);
        return res;
    }
}
