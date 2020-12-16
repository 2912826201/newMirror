

class NumberFormata{
 String getNumber(int number) {
    if(number==0||number==null){
      return 0.toString();
    }
    if (number < 10000) {
      return number.toString();
    } else {
      String db = "${(number / 10000).toString()}";
      if(int.parse(db.substring(db.indexOf(".")+1,db.indexOf(".")+2))!=0){
        String doubleText = db.substring(0, db.indexOf(".")+2);
        return doubleText + "W";
      }else{
        String intText = db.substring(0, db.indexOf("."));
        return intText +"W";
      }
    }
  }

}