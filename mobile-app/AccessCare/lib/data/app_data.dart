// lib/data/app_data.dart

const Map<String, List<Map<String, String>>> doctorsBySpecialty = {
  'Cardiology': [
    {
      'initials': 'SM',
      'name': 'Dr. Sarah Mohammed',
      'hospital': 'Dr. Alhabib - Takhasussi',
    },
    {'initials': 'YA', 'name': 'Dr. Yasmeen AlAmri', 'hospital': 'SMC'},
    {'initials': 'AG', 'name': 'Dr. Ahmad AlGhamdi', 'hospital': 'KFSHRC'},
    {
      'initials': 'FZ',
      'name': 'Dr. Faisal AlZahrani',
      'hospital': 'Dallah Hospital',
    },
  ],
  'Neurology': [
    {
      'initials': 'LR',
      'name': 'Dr. Layla AlRashid',
      'hospital': 'King Faisal Specialist',
    },
    {'initials': 'OH', 'name': 'Dr. Omar AlHarbi', 'hospital': 'KFSHRC'},
    {
      'initials': 'NO',
      'name': 'Dr. Nora AlOtaibi',
      'hospital': 'Alhabib - Olaya',
    },
    {'initials': 'KD', 'name': 'Dr. Khalid AlDosari', 'hospital': 'SMC'},
  ],
  'OB/GYN': [
    {
      'initials': 'HZ',
      'name': 'Dr. Hana AlZahrani',
      'hospital': 'Alhabib - Takhasussi',
    },
    {
      'initials': 'RM',
      'name': 'Dr. Reem AlShehri',
      'hospital': 'King Abdullah Medical',
    },
    {
      'initials': 'MQ',
      'name': 'Dr. Mona AlQahtani',
      'hospital': 'Dallah Hospital',
    },
    {'initials': 'SG', 'name': 'Dr. Sara AlGhamdi', 'hospital': 'KFSHRC'},
  ],
  'Ophthalmology': [
    {
      'initials': 'TM',
      'name': 'Dr. Tariq AlMutairi',
      'hospital': 'King Khalid Eye Specialist',
    },
    {'initials': 'LA', 'name': 'Dr. Lina AlAnazi', 'hospital': 'SMC'},
    {
      'initials': 'FS',
      'name': 'Dr. Faris AlShamari',
      'hospital': 'Alhabib - Alnarjis',
    },
    {
      'initials': 'DB',
      'name': 'Dr. Dina AlBarrak',
      'hospital': 'Dallah Hospital',
    },
  ],
  'Pediatrics': [
    {
      'initials': 'YS',
      'name': 'Dr. Yousef AlShalawi',
      'hospital': 'King Abdullah Specialist',
    },
    {'initials': 'AH', 'name': 'Dr. Amal AlHarthy', 'hospital': 'KFSHRC'},
    {'initials': 'BO', 'name': 'Dr. Badr AlOtaibi', 'hospital': 'SMC'},
    {
      'initials': 'RA',
      'name': 'Dr. Rasha AlAhmadi',
      'hospital': 'Alhabib - Olaya',
    },
  ],
  'Orthopedics': [
    {
      'initials': 'WS',
      'name': 'Dr. Waleed AlShammari',
      'hospital': 'King Faisal Specialist',
    },
    {
      'initials': 'GS',
      'name': 'Dr. Ghada AlSulami',
      'hospital': 'Dallah Hospital',
    },
    {'initials': 'NH', 'name': 'Dr. Nawaf AlHarbi', 'hospital': 'KFSHRC'},
    {'initials': 'ER', 'name': 'Dr. Eman AlRashidi', 'hospital': 'SMC'},
  ],
};

const Map<String, List<String>> weeksByMonth = {
  'April': [
    'Apr 1 - Apr 4',
    'Apr 5 - Apr 11',
    'Apr 12 - Apr 18',
    'Apr 19 - Apr 25',
    'Apr 26 - Apr 30',
  ],
  'May': [
    'May 1 - May 2',
    'May 3 - May 9',
    'May 10 - May 16',
    'May 17 - May 23',
    'May 24 - May 30',
    'May 31 - May 31',
  ],
  'June': [
    'Jun 1 - Jun 6',
    'Jun 7 - Jun 13',
    'Jun 14 - Jun 20',
    'Jun 21 - Jun 27',
    'Jun 28 - Jun 30',
  ],
};

const Map<String, List<Map<String, String>>> daysByWeek = {
  'Apr 1 - Apr 4': [
    {'day': 'Wed', 'date': '1'},
    {'day': 'Thu', 'date': '2'},
    {'day': 'Fri', 'date': '3'},
    {'day': 'Sat', 'date': '4'},
  ],
  'Apr 5 - Apr 11': [
    {'day': 'Sun', 'date': '5'},
    {'day': 'Mon', 'date': '6'},
    {'day': 'Tue', 'date': '7'},
    {'day': 'Wed', 'date': '8'},
    {'day': 'Thu', 'date': '9'},
    {'day': 'Fri', 'date': '10'},
    {'day': 'Sat', 'date': '11'},
  ],
  'Apr 12 - Apr 18': [
    {'day': 'Sun', 'date': '12'},
    {'day': 'Mon', 'date': '13'},
    {'day': 'Tue', 'date': '14'},
    {'day': 'Wed', 'date': '15'},
    {'day': 'Thu', 'date': '16'},
    {'day': 'Fri', 'date': '17'},
    {'day': 'Sat', 'date': '18'},
  ],
  'Apr 19 - Apr 25': [
    {'day': 'Sun', 'date': '19'},
    {'day': 'Mon', 'date': '20'},
    {'day': 'Tue', 'date': '21'},
    {'day': 'Wed', 'date': '22'},
    {'day': 'Thu', 'date': '23'},
    {'day': 'Fri', 'date': '24'},
    {'day': 'Sat', 'date': '25'},
  ],
  'Apr 26 - Apr 30': [
    {'day': 'Sun', 'date': '26'},
    {'day': 'Mon', 'date': '27'},
    {'day': 'Tue', 'date': '28'},
    {'day': 'Wed', 'date': '29'},
    {'day': 'Thu', 'date': '30'},
  ],
  'May 1 - May 2': [
    {'day': 'Fri', 'date': '1'},
    {'day': 'Sat', 'date': '2'},
  ],
  'May 3 - May 9': [
    {'day': 'Sun', 'date': '3'},
    {'day': 'Mon', 'date': '4'},
    {'day': 'Tue', 'date': '5'},
    {'day': 'Wed', 'date': '6'},
    {'day': 'Thu', 'date': '7'},
    {'day': 'Fri', 'date': '8'},
    {'day': 'Sat', 'date': '9'},
  ],
  'May 10 - May 16': [
    {'day': 'Sun', 'date': '10'},
    {'day': 'Mon', 'date': '11'},
    {'day': 'Tue', 'date': '12'},
    {'day': 'Wed', 'date': '13'},
    {'day': 'Thu', 'date': '14'},
    {'day': 'Fri', 'date': '15'},
    {'day': 'Sat', 'date': '16'},
  ],
  'May 17 - May 23': [
    {'day': 'Sun', 'date': '17'},
    {'day': 'Mon', 'date': '18'},
    {'day': 'Tue', 'date': '19'},
    {'day': 'Wed', 'date': '20'},
    {'day': 'Thu', 'date': '21'},
    {'day': 'Fri', 'date': '22'},
    {'day': 'Sat', 'date': '23'},
  ],
  'May 24 - May 30': [
    {'day': 'Sun', 'date': '24'},
    {'day': 'Mon', 'date': '25'},
    {'day': 'Tue', 'date': '26'},
    {'day': 'Wed', 'date': '27'},
    {'day': 'Thu', 'date': '28'},
    {'day': 'Fri', 'date': '29'},
    {'day': 'Sat', 'date': '30'},
  ],
  'May 31 - May 31': [
    {'day': 'Sun', 'date': '31'},
  ],
  'Jun 1 - Jun 6': [
    {'day': 'Mon', 'date': '1'},
    {'day': 'Tue', 'date': '2'},
    {'day': 'Wed', 'date': '3'},
    {'day': 'Thu', 'date': '4'},
    {'day': 'Fri', 'date': '5'},
    {'day': 'Sat', 'date': '6'},
  ],
  'Jun 7 - Jun 13': [
    {'day': 'Sun', 'date': '7'},
    {'day': 'Mon', 'date': '8'},
    {'day': 'Tue', 'date': '9'},
    {'day': 'Wed', 'date': '10'},
    {'day': 'Thu', 'date': '11'},
    {'day': 'Fri', 'date': '12'},
    {'day': 'Sat', 'date': '13'},
  ],
  'Jun 14 - Jun 20': [
    {'day': 'Sun', 'date': '14'},
    {'day': 'Mon', 'date': '15'},
    {'day': 'Tue', 'date': '16'},
    {'day': 'Wed', 'date': '17'},
    {'day': 'Thu', 'date': '18'},
    {'day': 'Fri', 'date': '19'},
    {'day': 'Sat', 'date': '20'},
  ],
  'Jun 21 - Jun 27': [
    {'day': 'Sun', 'date': '21'},
    {'day': 'Mon', 'date': '22'},
    {'day': 'Tue', 'date': '23'},
    {'day': 'Wed', 'date': '24'},
    {'day': 'Thu', 'date': '25'},
    {'day': 'Fri', 'date': '26'},
    {'day': 'Sat', 'date': '27'},
  ],
  'Jun 28 - Jun 30': [
    {'day': 'Sun', 'date': '28'},
    {'day': 'Mon', 'date': '29'},
    {'day': 'Tue', 'date': '30'},
  ],
};
