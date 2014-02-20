/**
 * 
 */

/*
 * Copyright 2007 The JA-SIG Collaborative. All rights reserved. See license
 * distributed with this file and available online at
 * http://www.uportal.org/license.html
 */

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.SocketTimeoutException;
import java.net.URL;
import java.net.URLEncoder;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;


public final class TestSsl {

	private static ExecutorService EXECUTOR_SERVICE = Executors.newFixedThreadPool(100);

	private static int connectionTimeout = 10000;

	private static int readTimeout = 10000;

	public static void main(final String[] args) {

		if ((args == null) || (args.length < 1) || (args.length > 2)) {
			System.out.println("Usage: TestSsl url [message]");
			return;
		}

		String url = args[0];
		String message = null;
		if (args.length > 1) {
			message = args[1];
		}

		TestSsl.sendMessageToEndPoint(url, message, false);

	}

	/**
	 * Sends a message to a particular endpoint.  Option of sending it without waiting to ensure a response was returned.
	 * <p>
	 * This is useful when it doesn't matter about the response as you'll perform no action based on the response.
	 *
	 * @param url the url to send the message to
	 * @param message the message itself
	 * @param async true if you don't want to wait for the response, false otherwise.
	 * @return boolean if the message was sent, or async was used.  false if the message failed.
	 */
	public static boolean sendMessageToEndPoint(final String url, final String message, final boolean async) {
		final Future<Boolean> result = TestSsl.EXECUTOR_SERVICE.submit(new MessageSender(url, message, TestSsl.readTimeout, TestSsl.connectionTimeout));

		if (async) {
			return true;
		}

		try {
			return result.get();
		} catch (final Exception e) {
			return false;
		}
	}

	private static final class MessageSender implements Callable<Boolean> {

		private String url;

		private String message;

		private int readTimeout;

		private int connectionTimeout;

		public MessageSender(final String url, final String message, final int readTimeout, final int connectionTimeout) {
			this.url = url;
			this.message = (message != null)? message : "defaultMessage";
			this.readTimeout = readTimeout;
			this.connectionTimeout = connectionTimeout;
		}

		@Override
		public Boolean call() throws Exception {
			HttpURLConnection connection = null;
			BufferedReader in = null;
			try {

				System.out.println("Attempting to access " + this.url);

				final URL logoutUrl = new URL(this.url);
				final String output = "logoutRequest=" + URLEncoder.encode(this.message, "UTF-8");

				connection = (HttpURLConnection) logoutUrl.openConnection();
				connection.setDoInput(true);
				connection.setDoOutput(true);
				connection.setRequestMethod("POST");
				connection.setReadTimeout(this.readTimeout);
				connection.setConnectTimeout(this.connectionTimeout);
				connection.setRequestProperty("Content-Length", Integer.toString(output.getBytes().length));
				connection.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
				final DataOutputStream printout = new DataOutputStream(connection.getOutputStream());
				printout.writeBytes(output);
				printout.flush();
				printout.close();

				in = new BufferedReader(new InputStreamReader(connection.getInputStream()));

				StringBuffer response = new StringBuffer(512);

				String text = in.readLine();
				while (text != null) {
					response.append(text);
					text = in.readLine();
				}

				System.out.println("Finished sending message to" + this.url);
				System.out.println("Response received: " + response.toString());

				return true;
			} catch (final SocketTimeoutException e) {
				System.out.println("Socket Timeout Detected while attempting to send message to [" + this.url + "].");
				return false;
			} catch (final Exception e) {
				System.out.println("Error Sending message to url endpoint [" + this.url + "].  Error is [" + e.getMessage() + "]");
				return false;
			} finally {
				if (in != null) {
					try {
						in.close();
					} catch (final IOException e) {
						// can't do anything
					}
				}
				if (connection != null) {
					connection.disconnect();
				}
			}
		}

	}
}


