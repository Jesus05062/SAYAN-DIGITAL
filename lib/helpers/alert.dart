import 'package:flutter/material.dart';

/* _showCredentials(
                        
                          BuildContext context,
                          String contrib,
                          String nombre,
                          String apMaterno,
                          String apPaterno,
                          String domicilio) {
                            ListView.builder(
                              itemCount: datos.length,
                              itemBuilder: (context, index) {
                                
                              },
                            );
                          } */

displayCustomAlert({
  required BuildContext context,
  required IconData icon,
  required String message,
  required Color color,
  String? title,
  String? redirectRoute,
}) {
  showDialog(
    //barrierDismissible: false,
    context: context,
    builder: (context) => AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 110),
          const SizedBox(height: 15),
          if (title != null)
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 25, color: Colors.grey.shade900),
            ),
          const SizedBox(height: 20),
          Text(
            message,
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade900),
          ),
        ],
      ),
      actions: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextButton(
              child: const Text(
                'Ok',
                style: TextStyle(fontSize: 18, color: Colors.indigo),
              ),
              onPressed: () => {
                if (redirectRoute == null)
                  Navigator.pop(context)
                else
                  Navigator.pushNamed(context, redirectRoute),
              },
            ),
          ],
        ),
      ],
    ),
  );
}

displayTimeOut({
  required BuildContext context,
  required IconData icon,
  required String message,
  required Color color,
  String? title,
  String? redirectRoute,
}) {
  showDialog(
    //barrierDismissible: false,
    context: context,
    builder: (context) => AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 110),
          const SizedBox(height: 15),
          if (title != null)
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 25, color: Colors.grey.shade900),
            ),
          const SizedBox(height: 20),
          Text(
            message,
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade900),
          ),
        ],
      ),
      actions: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextButton(
              child: const Text(
                'Ok',
                style: TextStyle(fontSize: 18, color: Colors.indigo),
              ),
              onPressed: () => {
                Navigator.pushReplacementNamed(context, 'validar_dni'),
              },
            ),
          ],
        ),
      ],
    ),
  );
}

displaySuccess({
  required BuildContext context,
  required IconData icon,
  required String message,
  required Color color,
  String? title,
  String? redirectRoute,
}) {
  showDialog(
    //barrierDismissible: false,
    context: context,
    builder: (context) => AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 110),
          const SizedBox(height: 15),
          if (title != null)
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 25, color: Colors.grey.shade900),
            ),
          const SizedBox(height: 20),
          Text(
            message,
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade900),
          ),
        ],
      ),
      actions: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextButton(
              child: const Text(
                'Ok',
                style: TextStyle(fontSize: 18, color: Colors.indigo),
              ),
              onPressed: () => {
                Navigator.pushReplacementNamed(context, 'inicio'),
              },
            ),
          ],
        ),
      ],
    ),
  );
}
