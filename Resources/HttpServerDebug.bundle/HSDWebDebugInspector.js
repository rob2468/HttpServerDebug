/**
 * get web view info
 */
function getWebViewInfo() {
  const title = document.title || document.location.href;
  const url = document.location.href;
  return { title, url };
}

/**
 * DOM.getDocument
 */
function getDocument() {
  const nodeData = visitHTMLElementDFS(document, 0);
  return {
    root: nodeData,
  };
}

function visitHTMLElementDFS(element, identifier) {
  let nodeData;
  if (element) {
    // visit children nodes
    const childNodesData = [];
    const childNodes = Array.from(element.childNodes);
    for (let i = 0; i < childNodes.length; i++) {
      const node = visitHTMLElementDFS(childNodes[i], identifier + 1);
      childNodesData.push(node);
    }

    // construct node structure
    nodeData = constructNode(element, identifier, childNodesData);
  }
  return nodeData;
}

/**
 *
 * @param {HTMLElement} element
 * @param {Number} identifier
 * @param {Array} children
 */
function constructNode(element, identifier, children) {
  const attributes = [];
  const attrs = element.attributes;
  if (attrs) {
    for (var i = 0; i < attrs.length; i++) {
      attributes.push(attrs[i].name, attrs[i].value);
    }
  }

  const nodeInfo = {
    nodeId: identifier,
    nodeName: element.nodeName,
    localName: element.localName,
    nodeType: element.nodeType,
    nodeValue: element.nodeValue,
    childNodeCount: element.childrenNodes && element.childrenNodes.length,
    attributes,
    children,
  };
  return nodeInfo;
}

// console.log(JSON.stringify(getDocument()));

// Test
document.body.style.backgroundColor = '#f00';

