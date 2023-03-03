// Java Program to Ping an IP address
import java.io.*;
import java.net.*;
  
class testPing
{
  // Aqui envio el ping para detectar algun error
  public static void sendPingRequest(String ipAddress)
              throws UnknownHostException, IOException
  {
    InetAddress geek = InetAddress.getByName(ipAddress);
    System.out.println("Enviando el ping a ... " + ipAddress);
    if (geek.isReachable(5000))
      System.out.println("El Host es alcanzable");
    else
      System.out.println("Sorry ! estamos en problemas, el Host no es alcanzable");
  }
  
  // Salida del resultado
  public static void main(String[] args)
          throws UnknownHostException, IOException
  {
    String ipAddress = "10.153.200.130";
    System.out.println("1- Nucleo de la red TI");
    sendPingRequest(ipAddress);

    ipAddress = "172.31.254.1";
    System.out.println("2- Distribución de servicios");
    sendPingRequest(ipAddress);

    ipAddress = "172.21.254.1";
    System.out.println("3- Dist. Edificio naranjo TI");
    sendPingRequest(ipAddress);

    ipAddress = "133.192.31.42";
    System.out.println("4- Ip de prueba");
    sendPingRequest(ipAddress);
  
    ipAddress = "145.154.42.58";
    System.out.println("5- Ip de prueba");
    sendPingRequest(ipAddress);
  }
}