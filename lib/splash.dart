import 'package:flutter/material.dart';
import 'package:my_store/home.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed( const Duration(seconds: 3),(){


      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => Home(),
      ));
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
            Text("MY ",

              style:TextStyle(fontSize: 40,
                fontStyle: FontStyle.italic,
                color: Colors.black87,


              ),
            ),
            //Text two Area
            Padding(
              padding: EdgeInsets.fromLTRB(100, 0, 0, 0),
              child: Text("STORE",
                style:TextStyle(fontSize: 35,

                  fontStyle: FontStyle.italic,
                  color: Colors.black87,
                ),
              ),
            ),

          ],
      )
      )
    );
  }
}
