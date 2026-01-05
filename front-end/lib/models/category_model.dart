class Category {
  final String name;
  final List<String> subCategories;

  Category({required this.name, required this.subCategories});
}

final categoriesData = [
  Category(
    name: 'Party & Decor',
    subCategories: ['LED Candles', 'Ramadan Decor'],
  ),
  Category(
    name: 'Art & Craft',
    subCategories: [
      'Art accessories',
      'Calligraphy Supplies',
      'Art Pencils & Pens',
      'Oil & Paints',
      'Art Combos',
    ],
  ),
  Category(
    name: 'Books',
    subCategories: [
      'Medical Books',
      'School Books',
      'College Books',
      'Past Papers',
      'O/A levels',
      'General Books',
      'Novels',
    ],
  ),
  Category(
    name: 'Schools',
    subCategories: [
      'Multan Public School(for girls  boys)',
      'Bloomfield Hall School',
      'The City School',
      'APSIS (Formally Garrison Academy)',
    ],
  ),
  Category(
    name: 'Medical',
    subCategories: ['Pulse Wear Scrubs', 'Pulse Wear Lab Coats'],
  ),
  Category(
    name: 'stationery',
    subCategories: [
      'Stationery Supplies',
      'School Supplies',
      'Writing Accessories',
      'Scientific Calculators',
      'Office Supplies',
    ],
  ),
  Category(
    name: 'Notebooks',
    subCategories: [
      'Notebook & Registers',
      'Spiral Notebooks',
      'Subject Notebooks',
      'Cards Register',
    ],
  ),
];
