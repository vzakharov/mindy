export first = {
  query: "Write a binary search algorithm"
  thoughts: "Binary search? Pff, easy. I’ll generate a code snippet and a mindmap to help memorize the basic concepts. I’ll use vanilla JavaScript so that it can be run right in the browser."
  reply: """
    Sure, take a look at this JavaScript code snippet. It’s a binary search algorithm, which is a **divide and conquer** algorithm that searches for an element in a **sorted array** by repeatedly **dividing the search interval in half**.
    
    While it’s **fast** and **easy to implement**, it only works on sorted arrays, so if you need to search for an element in an unsorted array, you’ll have to use a different algorithm.
    
    Ping me if you need help with that!
  """
  content:
    type: 'code'
    language: 'javascript'
    title: 'Binary search algorithm (JavaScript)'
    code: """
      // A function that searches for a target value in a sorted array
      function binarySearch(arr, target) {
      \tlet left = 0;
      \tlet right = arr.length - 1;
      \twhile (left <= right) {
      \t\tconst mid = Math.floor((left + right) / 2);
      \t\tif (arr[mid] === target) {
      \t\t\treturn mid;
      \t\t} else if (arr[mid] < target) {
      \t\t\tleft = mid + 1;
      \t\t} else {
      \t\t\tright = mid - 1;
      \t\t}
      \t}
      \treturn -1;
      }
    """
}