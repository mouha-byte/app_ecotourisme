import 'package:ecoguide/models/site_model.dart';
import 'package:ecoguide/models/itinerary_model.dart';
import 'package:ecoguide/models/booking_model.dart';

class MockDataService {
  static List<Site> getMockSites() {
    return [
      Site(
        id: '1',
        name: 'Plage Cap Negro',
        description:
            'Une plage sauvage exceptionnelle bordée par la forêt et les falaises. Le point de rencontre entre la montagne et la mer, idéal pour le camping et la détente.',
        latitude: 37.1000,
        longitude: 8.9833,
        photos: [
          'assets/images/sites/dune_pilat.jpg', // Plage / Sable
          'assets/images/sites/calanques.jpg', // Crique rocheuse
        ],
        animals: ['Loutres', 'Aigles de Bonelli', 'Sangliers'],
        plants: ['Pin d\'Alep', 'Maquis', 'Fleurs des sables'],
        ecoTips: [
          'Camping autorisé uniquement dans les zones dédiées',
          'Ne laissez aucune trace sur le sable',
          'Respectez la nidification des oiseaux',
        ],
        type: 'beach',
        rating: 4.8,
      ),
      Site(
        id: '2',
        name: 'Forêt de Djebel Chitana',
        description:
            'Un massif forestier dense de chênes-lièges surplombant la mer. Le terrain de jeu idéal pour le VTT et la randonnée sportive.',
        latitude: 37.0800,
        longitude: 9.0100,
        photos: [
          'assets/images/sites/camargue.jpg', // Swapped: used to be on Sylvagri
          'assets/images/sites/nature_detail.jpg',
        ],
        animals: ['Cerf de Barbarie', 'Renards', 'Genettes'],
        plants: ['Chêne-liège', 'Bruyère', 'Champignons sauvages'],
        ecoTips: [
          'Restez sur les sentiers balisés en VTT',
          'Attention aux risques d\'incendie',
          'Observez la faune en silence',
        ],
        type: 'forest',
        rating: 4.7,
      ),
      Site(
        id: '3',
        name: 'Sylvagri (Maison Nature)',
        description:
            'Centre d\'écotourisme et Maison Nature des Mogods. Vivez une immersion agricole et nature a Cap Negro : randonnées botaniques, pêche artisanale et découverte du terroir.',
        latitude: 37.0900,
        longitude: 9.0000,
        photos: [
          'assets/images/sites/fontainebleau_velo.jpg', // Swapped: used to be on Chitana
          'assets/images/sites/nature_detail.jpg',
        ],
        animals: ['Animaux de la ferme', 'Oiseaux migrateurs', 'Abeilles'],
        plants: ['Potager bio', 'Plantes aromatiques', 'Arbres fruitiers'],
        ecoTips: [
          'Participez aux activités agricoles',
          'Consommez les produits locaux',
          'Respectez le calme du lieu',
        ],
        type: 'reserve',
        rating: 4.9,
      ),
    ];
  }

  static List<Itinerary> getMockItineraries() {
    return [
      Itinerary(
        id: '1',
        name: 'Randonnée Botanique Guidée',
        description:
            'Une marche éducative au départ de Sylvagri pour découvrir les plantes médicinales et aromatiques de la région des Mogods. Accompagné par un guide local expert.',
        waypoints: [
          LatLngPoint(latitude: 37.0900, longitude: 9.0000),
          LatLngPoint(latitude: 37.0950, longitude: 9.0100),
          LatLngPoint(latitude: 37.0900, longitude: 9.0200),
        ],
        distanceKm: 5.0,
        durationMinutes: 120,
        transportMode: 'walking',
        difficulty: 'easy',
        siteIds: ['3', '2'],
        imageUrl: 'assets/images/sites/nature_detail.jpg',
        photos: [
          'assets/images/sites/nature_detail.jpg',
          'assets/images/sites/camargue.jpg',
        ],
        equipment: ['Carnet de notes', 'Chaussures de marche', 'Chapeau', 'Eau'],
        pointsOfInterest: ['Jardin botanique', 'Source naturelle', 'Vue panoramique'],
        bestSeason: 'Printemps (Floraison)',
        estimatedCarbonKg: 0,
        elevationGain: 100,
        region: 'Béja',
      ),
      Itinerary(
        id: '2',
        name: 'Randonnée Nocturne Mogods',
        description:
            'Une expérience sensorielle unique pour écouter la faune nocturne et observer le ciel étoilé loin de toute pollution lumineuse. Départ au crépuscule.',
        waypoints: [
          LatLngPoint(latitude: 37.0900, longitude: 9.0000),
          LatLngPoint(latitude: 37.0850, longitude: 8.9950),
        ],
        distanceKm: 3.0,
        durationMinutes: 90,
        transportMode: 'walking',
        difficulty: 'moderate',
        siteIds: ['3', '1'],
        imageUrl: 'assets/images/sites/calanques.jpg', // Nuit / Ambiance sombre
        photos: [
          'assets/images/sites/calanques.jpg',
          'assets/images/sites/dune_pilat.jpg',
        ],
        equipment: ['Lampe frontale (lumière rouge)', 'Vêtements chauds', 'Chaussures fermées'],
        pointsOfInterest: ['Chants des oiseaux de nuit', 'Observation des étoiles', 'Silence total'],
        bestSeason: 'Été',
        estimatedCarbonKg: 0,
        elevationGain: 50,
        region: 'Béja',
      ),
      Itinerary(
        id: '3',
        name: 'Circuit VTT Forêt & Mer',
        description:
            'Un parcours sportif reliant Sylvagri aux plages sauvages à travers la forêt de Djebel Chitana. Sensations fortes et paysages à couper le souffle.',
        waypoints: [
          LatLngPoint(latitude: 37.0900, longitude: 9.0000),
          LatLngPoint(latitude: 37.0800, longitude: 9.0100),
          LatLngPoint(latitude: 37.1000, longitude: 8.9833),
        ],
        distanceKm: 15.0,
        durationMinutes: 180,
        transportMode: 'cycling',
        difficulty: 'hard',
        siteIds: ['3', '2', '1'],
        imageUrl: 'assets/images/sites/fontainebleau_velo.jpg',
        photos: [
          'assets/images/sites/fontainebleau_velo.jpg',
          'assets/images/sites/dune_pilat.jpg',
        ],
        equipment: ['VTT', 'Casque', 'Gants', 'Kit réparation'],
        pointsOfInterest: ['Descente technique', 'Vue mer', 'Passage en forêt'],
        bestSeason: 'Automne et Printemps',
        estimatedCarbonKg: 0,
        elevationGain: 350,
        region: 'Béja',
      ),
    ];
  }

  static List<Activity> getMockActivities() {
    return [
      Activity(
        id: '1',
        name: 'Séjour Sylvagri (Pension)',
        description:
            'Hébergement en gîte rural écologique "Maison Nature". Pension complète avec cuisine du terroir bio (petit-déjeuner, déjeuner, dîner).',
        type: 'accommodation',
        pricePerPerson: 90.0,
        imageUrl: 'assets/images/sites/camargue.jpg',
        siteId: '3',
        isEcoFriendly: true,
        ecoLabels: ['Produits Locaux', 'Écotourisme'],
      ),
      Activity(
        id: '2',
        name: 'Atelier Pêche Artisanale',
        description:
            'Sortie en mer avec les pêcheurs locaux du Cap Negro. Découvrez les techniques de pêche traditionnelles respectueuses de la ressource.',
        type: 'activity',
        pricePerPerson: 45.0,
        imageUrl: 'assets/images/sites/calanques.jpg',
        siteId: '1',
        isEcoFriendly: true,
        ecoLabels: ['Pêche Durable'],
      ),
      Activity(
        id: '3',
        name: 'Initiation Agricole',
        description:
            'Participation aux travaux de la ferme à Sylvagri : potager, cueillette, soins aux animaux. Idéal pour les familles.',
        type: 'activity',
        pricePerPerson: 20.0,
        imageUrl: 'assets/images/sites/nature_detail.jpg',
        siteId: '3',
        isEcoFriendly: true,
        ecoLabels: ['Pédagogie Nature'],
      ),
    ];
  }
}
