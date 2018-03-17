({
  convertToTree: function (logEntries) {
    var items;
    var treeItemList = convertToTreeItems(logEntries);
    items = list_to_tree(treeItemList);
    return items;


    function convertToTreeItems(entries) {
      var treeItems = [];
      for (var i = 0; i < entries.length; i++) {
        var label = '';
        var entry = entries[i];
        if ($A.util.isEmpty(entry.description)) {
          label = entry.className + ': ' + entry.methodName + ' (' + entry.line + ',' + entry.column + ')';
        } else {
          label = entry.description + ' || [' + entry.className + ': ' + entry.methodName + ' (' + entry.line + ',' + entry.column + ')]';
        }
        var item = {
          "label": label,
          "name": entry.id + '',
          "parentId": entry.parentId + '',
          "expanded": entry.description.length > 0 ? true : false,
          "items": []
        };
        treeItems.push(item);
      }
      return treeItems;
    }

    function list_to_tree(list) {
      var map = {}, node, roots = [], i;
      for (i = 0; i < list.length; i += 1) {
        map[list[i].name] = i; // initialize the map
      }
      for (i = 0; i < list.length; i += 1) {
        node = list[i];
        if (node.parentId !== '0') {
          // if you have dangling branches check that map[node.parentId] exists
          list[map[node.parentId]].items.push(node);
        } else {
          roots.push(node);
        }
      }
      return roots;
    }
  }
})