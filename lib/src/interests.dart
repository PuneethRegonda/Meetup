class Interests {
  static int length = interests.length;

  static String getContent(int index) => interests[getTilte(index)];

  static String getTilte(int index) => interests.keys.toList()[index];

  static const Map<String, String> interests = {
    "Robotics":
        "A robot is a machine designed to execute one or more tasks automatically with speed and precision. There are as many different types of robots as there are tasks for them to perform.",
    "Drones":
        "A drone, in a technological context, is an unmanned aircraft. Drones are more formally known as unmanned aerial vehicles (UAV). Essentially, a drone is a flying robot.",
    "Artificial Intelligence":
        '''Artificial intelligence is the simulation of human intelligence processes by machines, especially computer systems.
The primary goals of AI include deduction and reasoning, knowledge representation, planning, natural language processing (NLP), learning, perception and the ability to manipulate and move objects.
''',
    "Machine Learning": '''Machine Learning
Machine learning is a type of artificial intelligence (AI) that provides computers with the ability to learn without being explicitly programmed. Machine learning focuses on the development of computer programs that can teach themselves to grow and change when exposed to new data.
''',
    "Nano Technology":
        "Nanomaterials are materials made from particles of nanoscale dimensions, produced by nanotechnology. The components measure below 100 nm. What makes nanomaterials unique are their two key characteristics. Their structure and their quantum effects.",
    "Augmented reality (AR)":
        "Augmented reality (AR) is an interactive experience of a real-world environment where the objects that reside in the real world are enhanced by computer-generated perceptual information, sometimes across multiple sensory modalities, including visual, auditory, haptic, somatosensory and olfactory.",
    "Virtual reality (VR) ":
        "Virtual reality (VR) is a simulated experience that can be similar to or completely different from the real world. The effect is commonly created by VR headsets consisting of a head-mounted display with a small screen in front of the eyes, but can also be created through specially designed rooms with multiple large screens.",
    "Big Data":
        "Big data means a large set (petabytes or gigabytes) of structured, unstructured or semi-structured data and analyzing those data to get the insights of the business trend.",
    "Internet of Things (IoT)":
        "Internet of Things (IoT) refers to a system of connected physical objects via the internet. The ‘thing’ in IoT can refer to a person or any device which is assigned through an IP address. A ‘thing’ collects and transfers data over the internet without any manual intervention with the help of embedded technology. It helps them to interact with the external environment or internal states to take the decisions."
  };
}
