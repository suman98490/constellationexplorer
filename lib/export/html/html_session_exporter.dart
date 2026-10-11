import 'dart:convert';

import '../../models/network_log.dart';
import '../../services/network_logger.dart';

class HtmlSessionExporter {
  String generate(List<NetworkLog> logs) {
    final successCount = logs.where((e) => e.success).length;
    final failureCount = logs.length - successCount;

    return '''
<!DOCTYPE html>

<html>

<head>

<meta charset="UTF-8">

<title>Constellation Explorer Session</title>

<style>

body{
    font-family:Arial;
    background:#F4F6F9;
    margin:0;
}

.header{

    background:#0F172A;

    color:white;

    padding:25px;

}

.header h1{

    margin:0;

}

.summary{

    display:flex;

    gap:25px;

    margin-top:20px;

}

.summary-card{

    background:#1E293B;

    padding:15px;

    border-radius:10px;

    min-width:120px;

}

.container{

    padding:20px;

}

.card{

    background:white;

    border-radius:12px;

    box-shadow:0 2px 8px rgba(0,0,0,.08);

    margin-bottom:20px;

    overflow:hidden;

}

.card-header{

    padding:16px;

    display:flex;

    justify-content:space-between;

    align-items:center;

    font-weight:bold;

}

.success{

    border-left:6px solid #16A34A;

}

.failed{

    border-left:6px solid #DC2626;

}

.method{

    display:inline-block;

    padding:4px 10px;

    border-radius:20px;

    color:white;

    font-size:12px;

    margin-right:10px;

}

.GET{

    background:#2563EB;

}

.POST{

    background:#16A34A;

}

.PATCH{

    background:#F59E0B;

}

.DELETE{

    background:#DC2626;

}

details{

    border-top:1px solid #ECECEC;

}

summary{

    cursor:pointer;

    padding:14px;

    font-weight:bold;

    background:#FAFAFA;

}

pre{

    margin:0;

    padding:15px;

    overflow:auto;

    background:white;

}

.folder{

    cursor:pointer;

    font-weight:bold;

    padding:8px;

}

.folder-content{

    margin-left:24px;

    margin-top:8px;

}

.section-header{

    margin-top:15px;

    margin-bottom:8px;

    padding-bottom:5px;

    border-bottom:1px solid #E5E7EB;

    color:#2563EB;

    font-weight:bold;

}

.property-row{

    display:flex;

    padding:6px 0;

    border-bottom:1px solid #F3F4F6;

}

.property-name{

    width:260px;

    font-weight:600;

    color:#374151;

}

.property-value{

    flex:1;

    color:#111827;

    word-break:break-word;

}

.copy-btn{

    float:right;

    background:#2563EB;

    color:white;

    border:none;

    border-radius:6px;

    padding:4px 10px;

    cursor:pointer;

    font-size:12px;

}

.copy-btn:hover{

    background:#1D4ED8;

}

</style>

</head>

<body>

<div class="header">

<h1>🚀 Constellation Explorer</h1>

<h3>Interactive Session Report</h3>

<div class="summary">

<div class="summary-card">
Total APIs
<br><br>
<b>${logs.length}</b>
</div>

<div class="summary-card">
Success
<br><br>
<b>$successCount</b>
</div>

<div class="summary-card">
Failed
<br><br>
<b>$failureCount</b>
</div>

<div class="summary-card">
Generated
<br><br>
<b>${DateTime.now()}</b>
</div>

</div>

</div>

<div class="container">

${logs.map(_buildApiCard).join("\n")}

</div>

<script>

function copyText(id, button){

    const text =
        document.getElementById(id).innerText;

    navigator.clipboard.writeText(text).then(() => {

        const originalText = button.innerHTML;

        button.innerHTML = "✅ Copied!";

        button.disabled = true;

        setTimeout(() => {

            button.innerHTML = originalText;

            button.disabled = false;

        }, 2000);

    });

}

</script>

</body>

</html>
''';
  }

  String _buildApiCard(NetworkLog log) {
    return '''

<div class="card ${log.success ? "success" : "failed"}">

<div class="card-header">

<div>

<span class="method ${log.method}">${log.method}</span>

${log.description}

</div>

<div>

${log.statusCode}

&nbsp;&nbsp;

${log.durationText}

</div>

</div>

<details>

<summary>General</summary>

<pre>

Method   : ${log.method}

Endpoint : ${log.endpoint}

Status   : ${log.statusCode}

Duration : ${log.durationText}

</pre>

</details>

<details>

<summary>🌳 Request (Tree View)</summary>

${_buildTree(
      log.request,
      "Request",
    )}

</details>

<details>

<summary>

📄 Request JSON

<button
    class="copy-btn"
    onclick="copyText('request${log.hashCode}', this)">

📋 Copy JSON

</button>

</summary>

<pre id="request${log.hashCode}">

${const JsonEncoder.withIndent("  ").convert(log.request)}

</pre>

</details>

<details>

<summary>🌳 Response (Tree View)</summary>

${_buildTree(
      log.response,
      "Response",
    )}

</details>

<details>

<summary>

📄 Response JSON

<button
    class="copy-btn"
    onclick="copyText('response${log.hashCode}', this)">

📋 Copy JSON

</button>

</summary>

<pre id="response${log.hashCode}">

${const JsonEncoder.withIndent("  ").convert(log.response)}

</pre>

</details>

</div>

''';
  }

  String _propertyRow(
      String property,
      dynamic value,
      ) {

    return """

<div class="property-row">

<div class="property-name">

$property

</div>

<div class="property-value">

${value ?? ""}

</div>

</div>

""";
  }

  String _sectionHeader(

      String icon,

      String title,

      ) {

    return """

<div class="section-header">

$icon $title

</div>

""";
  }

  String _buildTree(

      dynamic value,

      String title,

      ) {

    //--------------------------------------------------
    // MAP
    //--------------------------------------------------

    if (value is Map) {

      final properties = <MapEntry>[];
      final pages = <MapEntry>[];
      final pageLists = <MapEntry>[];

      for (final entry in value.entries) {

        if (entry.value is List) {

          pageLists.add(entry);

        }

        else if (entry.value is Map) {

          pages.add(entry);

        }

        else {

          properties.add(entry);

        }

      }

      final html = StringBuffer();

      html.writeln("""

<details>

<summary class="folder">

📁 $title

</summary>

<div class="folder-content">

""");

      //----------------------------------
      // Properties
      //----------------------------------

      if (properties.isNotEmpty) {

        html.writeln(

          _sectionHeader(

            "🔤",

            "Properties (${properties.length})",

          ),

        );

        for (final property in properties) {

          html.writeln(

            _propertyRow(

              property.key.toString(),

              property.value,

            ),

          );

        }

      }

      //----------------------------------
      // Pages
      //----------------------------------

      if (pages.isNotEmpty) {

        html.writeln(

          _sectionHeader(

            "📄",

            "Pages (${pages.length})",

          ),

        );

        for (final page in pages) {

          html.writeln(

            _buildTree(

              page.value,

              page.key.toString(),

            ),

          );

        }

      }

      //----------------------------------
      // Lists
      //----------------------------------

      if (pageLists.isNotEmpty) {

        html.writeln(

          _sectionHeader(

            "📚",

            "Page Lists (${pageLists.length})",

          ),

        );

        for (final list in pageLists) {

          html.writeln(

            _buildTree(

              list.value,

              list.key.toString(),

            ),

          );

        }

      }

      html.writeln("""

</div>

</details>

""");

      return html.toString();

    }

    //--------------------------------------------------
    // LIST
    //--------------------------------------------------

    if (value is List) {

      final html = StringBuffer();

      html.writeln("""

<details>

<summary class="folder">

📚 $title (${value.length})

</summary>

<div class="folder-content">

""");

      for (int i = 0; i < value.length; i++) {

        html.writeln(

          _buildTree(

            value[i],

            "[$i]",

          ),

        );

      }

      html.writeln("""

</div>

</details>

""");

      return html.toString();

    }

    //--------------------------------------------------
    // Primitive
    //--------------------------------------------------

    return _propertyRow(

      title,

      value,

    );

  }
}