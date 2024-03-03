import 'dart:ui';

class Audiobook {
  final int id;
  final String title;
  final String summary;
  final String author;
  final String bookCover;
  final Color color;
  final String url;
  String? localPath;

  Audiobook({
    required this.id,
    required this.title,
    required this.author,
    required this.url,
    required this.bookCover,
    required this.summary,
    required this.color,
    this.localPath,
  });
}

List<Audiobook> audiobooks = [
  Audiobook(
    id: 1,
    bookCover: "assets/images/hp1.jpg",
    title: "Harry Potter and the Philosopher’s Stone",
    author: "J.K. Rowling",
    summary:
        "Harry Potter thinks he is an ordinary boy - until he is rescued by an owl, taken to Hogwarts School of Witchcraft and Wizardry, learns to play Quidditch and does battle in a deadly duel. The Reason ... HARRY POTTER IS A WIZARD!",
    url: "https://free2.audiobookslab.com/audio/HP-1-By-Stephen-Fry/HP-and-the-philosopher-stone-audiobook-ch-1.mp3",
    color: const Color(0xff7F0406),
  ),
  Audiobook(
    id: 2,
    bookCover: "assets/images/hp2.jpg",
    title: "Harry Potter and the Chamber of Secrets",
    author: "J.K. Rowling",
    color: const Color(0xff005230),
    summary:
        "Ever since Harry Potter had come home for the summer, the Dursleys had been so mean and hideous that all Harry wanted was to get back to the Hogwarts School for Witchcraft and Wizardry. But just as he’s packing his bags, Harry receives a warning from a strange impish creature who says that if Harry returns to Hogwarts, disaster will strike.",
    url:
        "https://ipaudio5.com/wp-content/uploads/STARR/harr/Fry/2%20CHAMBER%20OF%20SECRETS/CH01%20THE%20WORST%20BIRTHDAY.mp3?_=1",
  ),
  Audiobook(
    id: 3,
    bookCover: "assets/images/hp4.png",
    title: "Harry Potter and the Prisoner of Azkaban",
    author: "J.K. Rowling",
    color: const Color(0xff530885),
    summary:
        "Harry Potter, along with his best friends, Ron and Hermione, is about to start his third year at Hogwarts School of Witchcraft and Wizardry. Harry can't wait to get back to school after the summer holidays. (Who wouldn't if they lived with the horrible Dursleys?) But when Harry gets to Hogwarts, the atmosphere is tense. There's an escaped mass murderer on the loose, and the sinister prison guards of Azkaban have been called in to guard the school...",
    url: "https://ipaudio5.com/wp-content/uploads/STARR/harr/Fry/3%20PRISONER%20OF%20AZKABAN/CH01%20OWL%20POST.mp3?_=1",
  ),
  Audiobook(
    id: 4,
    bookCover: "assets/images/hp6.jpg",
    title: "Harry Potter and the Half-Blood Prince",
    author: "J.K. Rowling",
    color: const Color(0xffEB5638),
    summary:
        "It is the middle of the summer, but there is an unseasonal mist pressing against the windowpanes. Harry Potter is waiting nervously in his bedroom at the Dursleys' house in Privet Drive for a visit from Professor Dumbledore himself. One of the last times he saw the Headmaster was in a fierce one-to-one duel with Lord Voldemort, and Harry can't quite believe that Professor Dumbledore will actually appear at the Dursleys' of all places. Why is the Professor coming to visit him now? What is it that cannot wait until Harry returns to Hogwarts in a few weeks' time? Harry's sixth year at Hogwarts has already got off to an unusual start, as the worlds of Muggle and magic start to intertwine",
    url: "https://free.audiobookslab.com/audio/the-last-wish-complete.mp3?_=1",
  ),
  Audiobook(
    id: 5,
    bookCover: "assets/images/hp7.jpg",
    title: "Harry Potter and the Deathly Hallows",
    author: "J.K. Rowling",
    color: const Color(0xff2C7C47),
    summary:
        "Harry has been burdened with a dark, dangerous and seemingly impossible task: that of locating and destroying Voldemort's remaining Horcruxes. Never has Harry felt so alone, or faced a future so full of shadows. But Harry must somehow find within himself the strength to complete the task he has been given. He must leave the warmth, safety and companionship of The Burrow and follow without fear or hesitation the inexorable path laid out for him...",
    url: "https://free.audiobookslab.com/audio/the-last-wish-complete.mp3?_=1",
  ),
];
