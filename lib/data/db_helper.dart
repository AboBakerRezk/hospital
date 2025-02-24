import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';


@HiveType(typeId: 0)
class Patient extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int age;

  @HiveField(3)
  String condition;

  @HiveField(4)
  int systolicBP;

  @HiveField(5)
  int diastolicBP;

  @HiveField(6)
  int heartRate;

  @HiveField(7)
  double weight;

  @HiveField(8)
  double height;

  @HiveField(9)
  double temperature;

  @HiveField(10)
  int respiratoryRate;

  @HiveField(11)
  int cholesterol;

  @HiveField(12)
  int bloodSugar;

  @HiveField(13)
  int oxygenSaturation;

  @HiveField(14)
  String smokingStatus;

  @HiveField(15)
  String exerciseFrequency;

  @HiveField(16)
  String medicalHistory;

  @HiveField(17)
  String medications;

  @HiveField(18)
  String notes;

  @HiveField(19)
  String analysisResult;

  @HiveField(20)
  String filePath;

  @HiveField(21)
  DateTime createdAt;

  @HiveField(22)
  DateTime updatedAt;

  Patient({
    this.id,
    required this.name,
    required this.age,
    required this.condition,
    required this.systolicBP,
    required this.diastolicBP,
    required this.heartRate,
    required this.weight,
    required this.height,
    required this.temperature,
    required this.respiratoryRate,
    required this.cholesterol,
    required this.bloodSugar,
    required this.oxygenSaturation,
    required this.smokingStatus,
    required this.exerciseFrequency,
    required this.medicalHistory,
    required this.medications,
    required this.notes,
    this.analysisResult = '',
    this.filePath = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();
}

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  Box<Patient>? _patientBox;

  /// يجب استدعاء هذه الدالة أثناء بدء تشغيل التطبيق لتهيئة Hive
  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(PatientAdapter());
    // حذف الصندوق القديم لتجنب تعارض البيانات مع النموذج الجديد
    await Hive.deleteBoxFromDisk('patientsBox');
    _patientBox = await Hive.openBox<Patient>('patientsBox');
  }


  /// إضافة مريض جديد إلى قاعدة البيانات
  Future<int> insertPatient(Patient patient) async {
    int id = await _patientBox!.add(patient);
    patient.id = id;
    await patient.save();
    return id;
  }

  /// جلب كل المرضى من قاعدة البيانات
  Future<List<Patient>> getAllPatients() async {
    return _patientBox!.values.toList();
  }

  /// تحديث بيانات مريض موجود
  Future<void> updatePatient(int id, Patient updatedPatient) async {
    final patient = _patientBox!.get(id);
    if (patient != null) {
      patient.name = updatedPatient.name;
      patient.age = updatedPatient.age;
      patient.condition = updatedPatient.condition;
      patient.systolicBP = updatedPatient.systolicBP;
      patient.diastolicBP = updatedPatient.diastolicBP;
      patient.heartRate = updatedPatient.heartRate;
      patient.weight = updatedPatient.weight;
      patient.height = updatedPatient.height;
      patient.temperature = updatedPatient.temperature;
      patient.respiratoryRate = updatedPatient.respiratoryRate;
      patient.cholesterol = updatedPatient.cholesterol;
      patient.bloodSugar = updatedPatient.bloodSugar;
      patient.oxygenSaturation = updatedPatient.oxygenSaturation;
      patient.smokingStatus = updatedPatient.smokingStatus;
      patient.exerciseFrequency = updatedPatient.exerciseFrequency;
      patient.medicalHistory = updatedPatient.medicalHistory;
      patient.medications = updatedPatient.medications;
      patient.notes = updatedPatient.notes;
      patient.analysisResult = updatedPatient.analysisResult;
      patient.filePath = updatedPatient.filePath;
      patient.updatedAt = DateTime.now();
      await patient.save();
    }
  }

  /// حذف مريض من قاعدة البيانات
  Future<void> deletePatient(int id) async {
    await _patientBox!.delete(id);
  }

  /// جلب مريض واحد بحسب المعرف
  Future<Patient?> getPatientById(int id) async {
    return _patientBox!.get(id);
  }
}
// GENERATED CODE - DO NOT MODIFY BY HAND


// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PatientAdapter extends TypeAdapter<Patient> {
  @override
  final int typeId = 0;

  @override
  Patient read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Patient(
      id: fields[0] as int?,
      name: fields[1] as String,
      age: fields[2] as int,
      condition: fields[3] as String,
      systolicBP: fields[4] as int,
      diastolicBP: fields[5] as int,
      heartRate: fields[6] as int,
      weight: fields[7] as double,
      height: fields[8] as double,
      temperature: fields[9] as double,
      respiratoryRate: fields[10] as int,
      cholesterol: fields[11] as int,
      bloodSugar: fields[12] as int,
      oxygenSaturation: fields[13] as int,
      smokingStatus: fields[14] as String,
      exerciseFrequency: fields[15] as String,
      medicalHistory: fields[16] as String,
      medications: fields[17] as String,
      notes: fields[18] as String,
      analysisResult: fields[19] as String,
      filePath: fields[20] as String,
      createdAt: fields[21] as DateTime,
      updatedAt: fields[22] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Patient obj) {
    writer
      ..writeByte(23)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.age)
      ..writeByte(3)
      ..write(obj.condition)
      ..writeByte(4)
      ..write(obj.systolicBP)
      ..writeByte(5)
      ..write(obj.diastolicBP)
      ..writeByte(6)
      ..write(obj.heartRate)
      ..writeByte(7)
      ..write(obj.weight)
      ..writeByte(8)
      ..write(obj.height)
      ..writeByte(9)
      ..write(obj.temperature)
      ..writeByte(10)
      ..write(obj.respiratoryRate)
      ..writeByte(11)
      ..write(obj.cholesterol)
      ..writeByte(12)
      ..write(obj.bloodSugar)
      ..writeByte(13)
      ..write(obj.oxygenSaturation)
      ..writeByte(14)
      ..write(obj.smokingStatus)
      ..writeByte(15)
      ..write(obj.exerciseFrequency)
      ..writeByte(16)
      ..write(obj.medicalHistory)
      ..writeByte(17)
      ..write(obj.medications)
      ..writeByte(18)
      ..write(obj.notes)
      ..writeByte(19)
      ..write(obj.analysisResult)
      ..writeByte(20)
      ..write(obj.filePath)
      ..writeByte(21)
      ..write(obj.createdAt)
      ..writeByte(22)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PatientAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;
}
