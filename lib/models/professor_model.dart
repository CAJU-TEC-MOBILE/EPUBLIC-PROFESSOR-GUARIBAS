// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class Professor {
  final String id;
  final String userId;
  final String nome;
  final String email;
  final String cpf;
  final String codigo;
  final String matricula;
  final String vinculo;
  final String dataNascimento;
  final String corOuRaca;
  final String municipalidade;
  final String naturalidade;
  final String estadualidade;
  final String nacionalidade;
  final String zonaResidencia;
  final String municipioResidencia;
  final String ufResidencia;
  final String paisResidencia;
  final String cep;
  final String filiacao1;
  final String filiacao2;
  final String roleId;

  Professor({
    required this.id,
    required this.userId,
    required this.nome,
    required this.email,
    required this.cpf,
    required this.codigo,
    required this.matricula,
    required this.vinculo,
    required this.dataNascimento,
    required this.corOuRaca,
    required this.municipalidade,
    required this.naturalidade,
    required this.estadualidade,
    required this.nacionalidade,
    required this.zonaResidencia,
    required this.municipioResidencia,
    required this.ufResidencia,
    required this.paisResidencia,
    required this.cep,
    required this.filiacao1,
    required this.filiacao2,
    required this.roleId,
  });

  factory Professor.fromJson(Map<dynamic, dynamic> json) {
    return Professor(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      nome: json['nome']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      cpf: json['cpf']?.toString() ?? '',
      codigo: json['codigo']?.toString() ?? '',
      matricula: json['matricula']?.toString() ?? '',
      vinculo: json['vinculo']?.toString() ?? '',
      dataNascimento: json['data_nascimento']?.toString() ?? '',
      corOuRaca: json['cor_ou_raca']?.toString() ?? '',
      municipalidade: json['municipalidade']?.toString() ?? '',
      naturalidade: json['naturalidade']?.toString() ?? '',
      nacionalidade: json['nacionalidade']?.toString() ?? '',
      estadualidade: json['estadualidade']?.toString() ?? '',
      zonaResidencia: json['zona_residencia']?.toString() ?? '',
      municipioResidencia: json['municipio_residencia']?.toString() ?? '',
      ufResidencia: json['uf_residencia']?.toString() ?? '',
      paisResidencia: json['pais_residencia']?.toString() ?? '',
      cep: json['cep']?.toString() ?? '',
      filiacao1: json['filiacao1']?.toString() ?? '',
      filiacao2: json['filiacao2']?.toString() ?? '',
      roleId: json['role_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'nome': nome,
      'email': email,
      'cpf': cpf,
      'codigo': codigo,
      'matricula': matricula,
      'vinculo': vinculo,
      'dataNascimento': dataNascimento,
      'cor_ou_raca': corOuRaca,
      'municipalidade': municipalidade,
      'naturalidade': naturalidade,
      'nacionalidade': nacionalidade,
      'estadualidade': estadualidade,
      'zona_residencia': zonaResidencia,
      'municipio_residencia': municipioResidencia,
      'uf_residencia': ufResidencia,
      'pais_residencia': paisResidencia,
      'cep': cep,
      'filiacao1': filiacao1,
      'filiacao2': filiacao2,
      'role_id': roleId,
    };
  }

  factory Professor.fromMap(Map<String, dynamic> map) {
    return Professor(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      nome: map['nome']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      cpf: map['cpf']?.toString() ?? '',
      codigo: map['codigo']?.toString() ?? '',
      matricula: map['matricula']?.toString() ?? '',
      vinculo: map['vinculo']?.toString() ?? '',
      dataNascimento: map['data_nascimento'] != null
          ? map['data_nascimento'].toString()
          : '',
      corOuRaca: map['cor_ou_raca']?.toString() ?? '',
      municipalidade: map['municipalidade']?.toString() ?? '',
      naturalidade: map['naturalidade']?.toString() ?? '',
      nacionalidade: map['nacionalidade']?.toString() ?? '',
      estadualidade: map['estadualidade']?.toString() ?? '',
      zonaResidencia: map['zona_residencia']?.toString() ?? '',
      municipioResidencia: map['municipio_residencia']?.toString() ?? '',
      ufResidencia: map['uf_residencia']?.toString() ?? '',
      paisResidencia: map['pais_residencia']?.toString() ?? '',
      cep: map['cep']?.toString() ?? '',
      filiacao1: map['filiacao1']?.toString() ?? '',
      filiacao2: map['filiacao2']?.toString() ?? '',
      roleId: map['role_id']?.toString() ?? '',
    );
  }

  static Professor empty() {
    return Professor(
      id: '',
      userId: '',
      nome: '',
      email: '',
      cpf: '',
      codigo: '',
      matricula: '',
      vinculo: '',
      dataNascimento: '',
      corOuRaca: '',
      municipalidade: '',
      naturalidade: '',
      estadualidade: '',
      nacionalidade: '',
      zonaResidencia: '',
      municipioResidencia: '',
      ufResidencia: '',
      paisResidencia: '',
      cep: '',
      filiacao1: '',
      filiacao2: '',
      roleId: '',
    );
  }

  String get dataDaAulaPtBr {
    try {
      final parsedDate = DateTime.parse(dataNascimento);
      return DateFormat('dd/MM/yyyy', 'pt_BR').format(parsedDate);
    } catch (e) {
      return dataNascimento.toString();
    }
  }

  String get dataDaAulaNumero {
    try {
      final parsedDate = DateTime.parse(dataNascimento);
      return DateFormat('ddMMyyyy').format(parsedDate);
    } catch (e) {
      return dataNascimento.toString();
    }
  }

  factory Professor.vazio() {
    return Professor(
      id: '',
      userId: '',
      nome: '',
      email: '',
      cpf: '',
      codigo: '',
      matricula: '',
      vinculo: '',
      dataNascimento: '',
      corOuRaca: '',
      municipalidade: '',
      naturalidade: '',
      nacionalidade: '',
      estadualidade: '',
      zonaResidencia: '',
      municipioResidencia: '',
      ufResidencia: '',
      paisResidencia: '',
      cep: '',
      filiacao1: '',
      filiacao2: '',
      roleId: '',
    );
  }
  @override
  String toString() {
    return 'Professor(id: $id, userId: $userId, nome: $nome, email: $email, cpf: $cpf, codigo: $codigo, matricula: $matricula, vinculo: $vinculo, dataNascimento: $dataNascimento, corOuRaca: $corOuRaca, municipalidade: $municipalidade, naturalidade: $naturalidade, estadualidade: $estadualidade, nacionalidade: $nacionalidade, zonaResidencia: $zonaResidencia, municipioResidencia: $municipioResidencia, ufResidencia: $ufResidencia, paisResidencia: $paisResidencia, cep: $cep, filiacao1: $filiacao1, filiacao2: $filiacao2, roleId: $roleId)';
  }
}

class ProfessorAdapter extends TypeAdapter<Professor> {
  @override
  final typeId = 43;

  @override
  Professor read(BinaryReader reader) {
    return Professor(
      id: reader.readString(),
      userId: reader.readString(),
      nome: reader.readString(),
      email: reader.readString(),
      cpf: reader.readString(),
      codigo: reader.readString(),
      matricula: reader.readString(),
      vinculo: reader.readString(),
      dataNascimento: reader.readString(),
      corOuRaca: reader.readString(),
      municipalidade: reader.readString(),
      naturalidade: reader.readString(),
      estadualidade: reader.readString(),
      nacionalidade: reader.readString(),
      zonaResidencia: reader.readString(),
      municipioResidencia: reader.readString(),
      ufResidencia: reader.readString(),
      paisResidencia: reader.readString(),
      cep: reader.readString(),
      filiacao1: reader.readString(),
      filiacao2: reader.readString(),
      roleId: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Professor obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.userId);
    writer.writeString(obj.nome);
    writer.writeString(obj.email);
    writer.writeString(obj.cpf);
    writer.writeString(obj.codigo);
    writer.writeString(obj.matricula);
    writer.writeString(obj.vinculo);
    writer.writeString(obj.dataNascimento);
    writer.writeString(obj.corOuRaca);
    writer.writeString(obj.municipalidade);
    writer.writeString(obj.naturalidade);
    writer.writeString(obj.estadualidade);
    writer.writeString(obj.nacionalidade);
    writer.writeString(obj.zonaResidencia);
    writer.writeString(obj.municipioResidencia);
    writer.writeString(obj.ufResidencia);
    writer.writeString(obj.paisResidencia);
    writer.writeString(obj.cep);
    writer.writeString(obj.filiacao1);
    writer.writeString(obj.filiacao2);
    writer.writeString(obj.roleId);
  }
}
