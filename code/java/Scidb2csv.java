import java.io.File;
import java.io.FileNotFoundException;
import java.util.Scanner;

public class Scidb2csv {

    static class Record {
        int x, y, val;
        @Override
        public String toString() {
            return x +" " + y + " " + val;
        }
    }

    /**
     * @param args
     * @throws FileNotFoundException
     */
    public static void main(String[] args) throws FileNotFoundException {
        // TODO Auto-generated method stub

        

        Scanner sc = new Scanner(new File(args[0]));

        while (sc.hasNext()) {
            if (sc.next().equals("(")) {
                Record r = new Record();
                r.x = sc.nextInt();
                r.y = sc.nextInt();
                r.val = sc.nextInt();
System.out.println(r);
            } else System.out.println(sc.next());

        }
    }

}

