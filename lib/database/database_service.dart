import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();

  Database? _database;

  Future<Database> get database async {
    // Se já existe uma conexão aberta,
    // simplesmente retornamos.
    if (_database != null) {
      return _database!;
    }

    // Caso contrário, inicializamos.
    _database = await _initDatabase();

    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String databasePath = await getDatabasesPath();
    final String path = join(databasePath, 'ordem_servico.db');

    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE clientes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        documento TEXT NOT NULL,
        telefone TEXT NOT NULL,
        email TEXT NOT NULL,
        endereco TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE tecnicos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        contato TEXT NOT NULL,
        especialidade TEXT NOT NULL,
        situacao TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE equipamentos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cliente_id INTEGER NOT NULL,
        tipo TEXT NOT NULL,
        marca TEXT NOT NULL,
        modelo TEXT NOT NULL,
        numero_serie TEXT,
        observacoes TEXT,
        FOREIGN KEY (cliente_id)
          REFERENCES clientes(id)
          ON DELETE RESTRICT
      )
    ''');

    await db.execute('''
      CREATE TABLE ordens_servico (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        numero TEXT NOT NULL UNIQUE,
        cliente_id INTEGER NOT NULL,
        equipamento_id INTEGER NOT NULL,
        tecnico_id INTEGER,
        descricao_problema TEXT NOT NULL,
        prioridade TEXT NOT NULL,
        status TEXT NOT NULL,
        data_abertura TEXT NOT NULL,
        data_limite TEXT NOT NULL,
        diagnostico TEXT ,
        solucao TEXT ,
        valor_mao_de_obra REAL NOT NULL DEFAULT 0,
        FOREIGN KEY (cliente_id)
          REFERENCES clientes(id)
          ON DELETE RESTRICT,
        FOREIGN KEY (equipamento_id)
          REFERENCES equipamentos(id)
          ON DELETE RESTRICT,
        FOREIGN KEY (tecnico_id)
          REFERENCES tecnicos(id)
          ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE itens_ordem_servico (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ordem_servico_id INTEGER NOT NULL,
        descricao TEXT NOT NULL,
        quantidade INTEGER NOT NULL,
        valor_unitario REAL NOT NULL,
        FOREIGN KEY (ordem_servico_id)
          REFERENCES ordens_servico(id)
          ON DELETE CASCADE
      )
    ''');
  }
}
