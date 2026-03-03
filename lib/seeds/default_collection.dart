import 'package:weakest_link/classes/question.dart';
import 'package:weakest_link/classes/question_collection.dart';

class DefaultQuestionCollection {
  static QuestionCollection getDefaultSeed() {
    final List<Question> questions = [
      Question(title: "Με ποιο όργανο του προσώπου δουλεύει κυρίως κάποιος ο οποίος κάνει “σπικάζ”", answer: "με το στόμα", difficulty: 1),
      Question(title: "Τι σχήμα είχε το τηλεοπτικό σύμβολο με πράσινο φόντο “κατάλληλο για όλους”", answer: "ρόμβο", difficulty: 1),
      Question(title: "Από ποια χώρα κατάγεται το μπιλιάρδο “καραμπόλα” — παίζεται με τρεις μπάλες και δεν έχει τρύπες το τραπέζι", answer: "Γαλλία", difficulty: 1),
      Question(title: "Το μουσικό όργανο Ουντ είναι έγχορδο ή πνευστό;", answer: "έγχορδο", difficulty: 1),
      Question(title: "Ο σταθμός της γραμμής 2 του μετρό Συγγρού - Φιξ, έχει ή δεν έχει σύνδεση με τραμ;", answer: "έχει", difficulty: 1),
      Question(title: "Πώς λέγεται το σκυλί που έχουν οι βοσκοί για να προσέχουν τα πρόβατα;", answer: "τσοπανόσκυλο", difficulty: 1),
      Question(title: "Σε ποιό άθλημα έχει αναγνωριστεί διεθνώς ο Νίκος Γκάλης;", answer: "Μπάσκετ", difficulty: 1),
      Question(title: "Τι χρονικό όριο έχει ένα σετ βόλλεϋ;", answer: "απεριόριστο/μέχρι να σκάσει η μπάλα κάτω", difficulty: 1),
      Question(title: "Πώς λέγεται το όργανο ενός όπλου, το οποίο το τραβάμε για να πυροβολήσουμε;", answer: "σκανδάλη", difficulty: 1),
      Question(title: "Ποιά ήταν η κύρια ανησυχία/ο κύριος φόβος των ΗΠΑ κατά τη διάρκεια του ψυχρού πολέμου;", answer: "ο κομμουνισμός", difficulty: 1),
      Question(title: "Το Όρεγκον ή το Κολοράδο βρέχεται από ωκεανό;", answer: "το Όρεγκον", difficulty: 1),
      Question(title: "Πώς λέγεται η εκπομπή της Αγγελικής Νικολούλη, όπου διερρευνά διάφορα μυστήρια γεγονότα εγκληματικής απόχρωσης: Φως στο…;", answer: "τούνελ", difficulty: 1),
      Question(title: "Σε τι είδους καύσιμο αναφέρεται ένα βενζινάδικο όταν γράφει CNG;", answer: "Φυσικό Αέριο", difficulty: 1),
      Question(title: "Ποιός διάσημος τραγουδιστής και τραγουδοποιός έγραψε το κομμάτι “σβήσε το φεγγάρι”", answer: "Δημήτρης Μητροπάνος", difficulty: 1),
      Question(title: "Ο διάσημος διεθνής καλαθοσφαιριστής Βασίλης Σπανούλης έχει ή δεν έχει παίξει στο NBA;", answer: "έχει παίξει", difficulty: 1),
      Question(title: "Ποιός ήταν ο πρώτος παρουσιαστής της εκπομπής “Ποιός Θέλει να Γίνει Εκατομμυριούχος” στην Ελλάδα;", answer: "ο Σπύρος Παπαδόπουλος", difficulty: 1),
      Question(title: "Ποιές δύο γραμμές μετρό συνδέει ο σταθμός “Αττική”;", answer: "Γραμμή 1 και 2, ή κόκκινη και πράσινη", difficulty: 1),
      Question(title: "Σε ποιο σύμπλεγμα νησιών ανήκει η Σκύρος;", answer: "σποράδες", difficulty: 1),
      Question(title: "Ποιά μάρκα αυτοκινήτων βγάζει το μοντέλο Multipla;", answer: "Fiat", difficulty: 1),
      Question(title: "Ποιόν χαρακτήρα έπαιζε στα φιλαράκια η Τζένιφερ Άνιστον;", answer: "Ρέιτσελ", difficulty: 1),
      Question(title: "Σε ποιό άθλημα ήταν διεθνώς αναγνωρισμένος ο Αργεντίνος αθλητής Ντιέγκο Μαραντόνα;", answer: "ποδόσφαιρο", difficulty: 1),
      Question(title: "Στη Β’ Λυκείου, ποιά δύο μαθήματα βρίσκονται στην ομάδα προσανατολισμού θετικών σπουδών; Μαθηματικά και…;", answer: "Φυσική", difficulty: 1),
      Question(title: "Σε ποιό ελληνικό σίριαλ βρίσκαμε τους πρωταγωνιστές και αστυνομικούς Λουκά, Θωμά και Προκόπη;", answer: "LAPD", difficulty: 1),
      Question(title: "Στα αρχικά της Γ.Α.Δ.Α. τι σημαίνει το γράμμα Δ;", answer: "Διεύθυνση", difficulty: 1),
      Question(title: "Ποιό υπερδιάσημο ελληνικό όνομα γιορτάζει στις 7 Ιανουαρίου;", answer: "Γιάννης και η Γιάννα", difficulty: 1),
      Question(title: "Γαλλικός όρος, μίας λέξης, που χρησιμοποιούμε για το εκπώμαστρο", answer: "τιρμπουσόν", difficulty: 1),
      Question(title: "Πώς λεγόταν ο ηθοποιός που έπαιζε τον Παρασκευά στο netwix;", answer: "Φάνης Λαμπρόπουλος", difficulty: 1),
      Question(title: "Ο ποδοσφαιριστής Σεμπάστιαν Λέτο το 2010 πήγε από τον Ολυμπιακό στον Παναθηναϊκό, ή από τον Παναθηναϊκό στον Ολυμπιακό;", answer: "από τον Ολυμπιακό στον Παναθηναϊκό", difficulty: 1),
      Question(title: "Το Μονακό είναι ή δεν είναι ανεξάρτητο κράτος;", answer: "είναι", difficulty: 1),
      Question(title: "Ποιά είναι η πρωτεύουσα της Αυστραλίας;", answer: "Καμπέρα", difficulty: 1),
      Question(title: "Πώς λέγεται η επιστήμη που μελετά τους σεισμούς;", answer: "Σεισμολογία", difficulty: 1),
      Question(title: "Ποιος πλανήτης είναι γνωστός ως ο «Κόκκινος Πλανήτης»;", answer: "Άρης", difficulty: 1),
      Question(title: "Πώς λέγεται στα αγγλικά η πετοσφαίρηση;", answer: "volley - volleyball", difficulty: 1),
      Question(title: "Πώς είναι ο Ελληνικός όρος του αθλήματος tennis;", answer: "αντισφαίρηση", difficulty: 1),
      Question(title: "Η περιφερειακή ενότητα Αργολίδας είναι ή δεν είναι στην Πελοπόννησο;", answer: "είναι", difficulty: 1),
      Question(title: "Τι σημαίνει η αραβικής καταγωγής λέξη “ζιμπάλα”;", answer: "σκουπίδια - κάδος απορρημάτων", difficulty: 1),
      Question(title: "Όταν κάποιος είναι σε μία θέση, στην οποία τον έχει βάλει κάποιος γνωστός του, λέμε ότι είναι…;", answer: "βυσματίας", difficulty: 1),
      Question(title: "Για κάποιον ο οποίος είναι τίμιος και του συμβαίνει κάτι καλό, ο ίδιος λέει ότι “ο Θεός αγαπάει τον κλέφτη, αλλά αγαπάει και τον…;”", answer: "νοικοκύρη", difficulty: 1),
      Question(title: "Ποιός πολιτικός είπε την φράση “Που τα βρήκατε αυτά τα φυντάνια;”", answer: "Δημήτρης Κουτσούμπας", difficulty: 1),
      Question(title: "Το Πάσχα θεωρείται κινητή ή ακίνητη εορτή;", answer: "κινητή", difficulty: 1),
      Question(title: "Ποιός πλανήτης του ηλιακού συστήματος έχει ένα χαρακτηριστικό γαλανό χρώμα, και έχει κλίση 90 μοιρών;", answer: "Ουρανός", difficulty: 1),
      Question(title: "Ποιανού συγκροτήματος υπήρξε κιθαρίστας ο John Lennon;", answer: "των Beatles", difficulty: 1),
      Question(title: "Σε ποιάς πόλης το Πανεπιστήμιο σπούδαζε ο Θεωρητικός Φυσικός Άλμπερτ Αϊνστάιν;", answer: "της Ζυρίχης", difficulty: 1),
      Question(title: "Ποιός πρόεδρος των Ηνωμένων Πολιτειών δολοφονήθηκε κατά τη διάρκεια του Ψυχρού Πολέμου;", answer: "Τζον Κέννεντι", difficulty: 1),
      Question(title: "Γαλλικός όρος μίας λέξης, για τον σταθμό επισκευής ή αλλαγής ελαστικών αυτοκινήτου.", answer: "βουλκανιζατέρ", difficulty: 1),
      Question(title: "Η Ελλάδα βρέχεται ή δεν βρέχεται από την Μαύρη Θάλασσα;", answer: "δεν βρέχεται", difficulty: 1),
      Question(title: "Ποιό εξάρτημα του αυτοκινήτου καθαρίζει τα καυσαέρια πριν βγουν από την εξάτμιση;", answer: "καταλύτης", difficulty: 1),
      Question(title: "Με ποιο ψευδώνυμο ήταν γνωστός ο Walter White στο κόσμο των ναρκωτικών στη σειρά Breaking Bad;", answer: "Heisenberg", difficulty: 1),
      Question(title: "Σύμφωνα με το αρχαίο ρητό, τι ΔΕΝ είναι ένας Άνδρας όταν δισεξαμαρταίνει;", answer: "Σοφός", difficulty: 1),
    ];

    return QuestionCollection(
      title: 'Default',
      questions: questions
    );
  }
}