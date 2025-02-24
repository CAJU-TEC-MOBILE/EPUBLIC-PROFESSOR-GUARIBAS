import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';

class DirectoriesController {
  Future<void> getStorageDirectories() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    print("Diretório de Documentos (Persistente): ${appDocDir.path}");

    Directory tempDir = await getTemporaryDirectory();
    print("Diretório Temporário (Dados Temporários): ${tempDir.path}");

    if (Platform.isAndroid) {
      Directory? externalDir = await getExternalStorageDirectory();

      if (externalDir != null) {
        print("Diretório Externo (Android): ${externalDir.path}");
      } else {
        print("O diretório externo não está disponível.");
      }
    }
  }

  Future<void> createImageDirectory() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();

    Directory imageDir = Directory('${appDocDir.path}/images');

    if (!(await imageDir.exists())) {
      await imageDir.create(recursive: true);
      print("Pasta 'image' criada em: ${imageDir.path}");
    } else {
      print("A pasta 'image' já existe em: ${imageDir.path}");
    }
  }

  Future<void> createAnexoDirectory() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();

    Directory imageDir = Directory('${appDocDir.path}/anexos');

    if (!(await imageDir.exists())) {
      await imageDir.create(recursive: true);
      print("Pasta 'anexos' criada em: ${imageDir.path}");
      return;
    }
    print("A pasta 'anexos' já existe em: ${imageDir.path}");
  }

  Future<void> createAnexoLocalDirectory() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();

    Directory imageDir = Directory('${appDocDir.path}/anexosLocal');

    if (!(await imageDir.exists())) {
      await imageDir.create(recursive: true);
      print("Pasta 'anexos' criada em: ${imageDir.path}");
      return;
    }
    print("A pasta 'anexos' já existe em: ${imageDir.path}");
  }

  Future<String> obterCaminhoDoAnexo() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory imageDir = Directory('${appDocDir.path}/anexos');
    if (await imageDir.exists()) {
      return imageDir.path;
    }
    await imageDir.create(recursive: true);
    return imageDir.path;
  }

  Future<String> obterCaminhoDoAnexoLocal() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory imageDir = Directory('${appDocDir.path}/anexosLocal');
    if (await imageDir.exists()) {
      return imageDir.path;
    }
    await imageDir.create(recursive: true);
    return imageDir.path;
  }

  Future<List<File>> getodosArquivosAnexos() async {
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      Directory anexosDir = Directory('${appDocDir.path}/anexos');

      if (!await anexosDir.exists()) {
        await anexosDir.create(recursive: true);
        return [];
      }

      List<File> arquivos = anexosDir.listSync().whereType<File>().toList();

      return arquivos;
    } catch (e) {
      print('Erro ao obter arquivos do diretório de anexos: $e');
      return [];
    }
  }

  Future<void> excluirTudoAnexos() async {
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      Directory anexosDir = Directory('${appDocDir.path}/anexos');

      if (await anexosDir.exists()) {
        for (var entity in anexosDir.listSync(recursive: true)) {
          if (entity is File) {
            entity.deleteSync();
          } else if (entity is Directory) {
            entity.deleteSync(recursive: true);
          }
        }
      }
    } catch (e) {
      print('Erro ao excluir tudo do diretório de anexos: $e');
    }
  }

  Future<String> getDiretorioImages() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory imageDir = Directory('${appDocDir.path}/images');

    if (await imageDir.exists()) {
      return imageDir.path;
    } else {
      await imageDir.create(recursive: true);
      return imageDir.path;
    }
  }

  Future<String> saveImage(File imageFile) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory imageDir = Directory('${appDocDir.path}/images');

    if (!(await imageDir.exists())) {
      await imageDir.create(recursive: true);
    }

    String imagePath =
        '${imageDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    File savedImage = await imageFile.copy(imagePath);

    print("Imagem salva em: $imagePath");

    return imagePath;
  }

  Future<String> saveImageUser(
      File imageFile, String? userId, String? fileName) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory imageDir = Directory('${appDocDir.path}/images');

    if (!(await imageDir.exists())) {
      await imageDir.create(recursive: true);
    }

    String fileExtension = extension(imageFile.path);
    String fileNameWithoutExtension = fileName!.split('.').first;
    String imagePath =
        '${imageDir.path}/${fileNameWithoutExtension}_${userId}$fileExtension';

    print('imagePath: $imagePath');

    File existingImage = File(imagePath);

    await deleteImagesByUserId(userId);
    print("Imagem antiga removida: $imagePath");

    File savedImage = await imageFile.copy(imagePath);
    print("Imagem salva em: $imagePath");

    return imagePath;
  }

  Future<void> pickAndSaveImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File imageFile = File(image.path);
      await saveImage(imageFile);
    }
  }

  Future<void> pickAndSaveImageUser({required String? userId}) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File imageFile = File(image.path);
      String fileName = basename(image.name);
      print("Nome do arquivo: $fileName");
      await saveImageUser(imageFile, userId, fileName);
    }
  }

  Future<void> pickAndSaveImageUserHttp({
    required String? userId,
    required File file,
  }) async {
    try {
      String fileName = basename(file.path);
      print('fileName: ++++ $fileName');
      print("Nome do arquivo: $fileName");

      await saveImageUser(file, userId, fileName);
    } catch (error) {
      print("Erro ao processar a imagem: $error");
    }
  }

  Future<File?> getImageUser(String? userId) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory imageDir = Directory('${appDocDir.path}/images');

    // Verifica se o diretório existe
    if (!(await imageDir.exists())) {
      print("Diretório de imagens não encontrado.");
      return null;
    }

    List<FileSystemEntity> files = imageDir.listSync();

    for (var file in files) {
      if (file is File) {
        String fileName = basename(file.path);
        if (fileName.contains('_$userId')) {
          print("Imagem encontrada: ${file.path}");
          return file;
        }
      }
    }
  }

  Future<void> clearImagesDirectory() async {
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      Directory imageDir = Directory('${appDocDir.path}/images');

      if (await imageDir.exists()) {
        List<FileSystemEntity> files = imageDir.listSync();

        for (FileSystemEntity file in files) {
          await file.delete();
          print('Imagem deletada: ${file.path}');
        }
      } else {
        print('O diretório de imagens não existe.');
      }
    } catch (e) {
      print('Erro ao limpar o diretório de imagens: $e');
    }
  }

  Future<List<File>> getAllUserImages() async {
    List<File> images = [];
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      Directory imageDir = Directory('${appDocDir.path}/images');

      if (!(await imageDir.exists())) {
        print("Diretório de imagens não encontrado.");
        return images;
      }

      List<FileSystemEntity> files = imageDir.listSync();

      for (var file in files) {
        print('file: $file');
      }
      print("Imagens encontradas: ${images.length}");
    } catch (e) {
      print("Erro ao obter imagens: $e");
    }
    return images;
  }

  Future<void> deleteImagesByUserId(String? userId) async {
    if (userId == null || userId.isEmpty) {
      print("UserId inválido.");
      return;
    }

    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory imageDir = Directory('${appDocDir.path}/images');

    if (!(await imageDir.exists())) {
      print("Diretório de imagens não encontrado.");
      return;
    }

    List<FileSystemEntity> files = imageDir.listSync();

    for (var file in files) {
      if (file is File) {
        String fileName = basename(file.path);
        if (fileName.contains('_$userId')) {
          try {
            file.deleteSync(); // Usando o método síncrono deleteSync
            print("Imagem deletada: ${file.path}");
          } catch (e) {
            print("Erro ao deletar imagem: ${file.path}. Erro: $e");
          }
        }
      }
    }
  }

  Future<String> saveFile(
      File imageFile, String? criadaPeloCelular, String? fileName) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory imageDir = Directory('${appDocDir.path}/anexosLocal');

    if (!(await imageDir.exists())) {
      await imageDir.create(recursive: true);
    }

    String fileExtension = extension(imageFile.path);
    String fileNameWithoutExtension = fileName!.split('.').first;
    String imagePath =
        '${imageDir.path}/${fileNameWithoutExtension}_${criadaPeloCelular}$fileExtension';

    File existingImage = File(imagePath);

    print("Imagem antiga removida: $imagePath");

    File savedImage = await imageFile.copy(imagePath);
    print("Imagem salva em: $imagePath");

    return imagePath;
  }
}
