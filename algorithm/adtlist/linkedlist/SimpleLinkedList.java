package adtlist.linkedlist;

public class SimpleLinkedList<T> {

    private Node headNode;
    private Node bottomNode;
    private int size;
    public SimpleLinkedList() {
        this.headNode = null;
        this.bottomNode = null;
        this.size = 0;
    }

    public Node get(int index) {
        Node currentNode = headNode;

        for (int i = 0; i <= index - 1 ; i++) {
            currentNode = currentNode.getNextNode();
        }

        return currentNode;
    }

    public void add(T data, int index) {
        if (index == 0) {
            Node newHeadNode = new Node(data, this.headNode);
            this.headNode = newHeadNode;
        } else {
            Node currentNode = get(index - 1);
            Node nextNode = new Node(data, currentNode.getNextNode());
            currentNode.setNextNode(nextNode);
        }

        this.size++;
    }

    public void addFirst(T data) {
        this.add(data, 0);
    }

    public void addBot(T data) {
        /*this.bottomNode = get(this.size - 1);
        Node newNode = new Node(data);
        this.bottomNode.setNextNode(newNode);
        this.bottomNode = newNode;
        this.size++;*/
        this.add(data, this.size);
    }

    public T removeTop() {

        Node removedNode = this.headNode;

        if (this.size < 1) {
            this.headNode = null;

            this.size--;
            return removedNode.getData();
        }


        this.headNode = this.headNode.getNextNode();

        this.size--;

        return removedNode.getData();
    }

    public T removeBot() {

        Node removedNode = get(this.size - 1);

        if (this.size == 1) {

            this.removeIndex(0);
            return removedNode.getData();
        }


        this.bottomNode = get(this.size - 2);
        this.bottomNode.setNextNode(null);

        this.size--;

        return removedNode.getData();
    }

    private int[] findIndexes(T data) {

        if (!isContain(data)) {
            return null;
        }

        int count = 0;

        for (int i = 0; i < this.size; i++) {
            if (this.get(i).getData().equals(data)) {
                count++;
            }
        }

        int[] indexes = new int[count];

        count = 0;

        for (int i = 0; i < this.size; i++) {
            if (this.get(i).getData().equals(data)) {
                indexes[count] = i;
                count++;
            }
        }

        return indexes;
    }

    public void removeIndex(int index) {
        Node currentNode = get(index - 1);

        if (index == 0) {
            this.removeTop();
            return;
        }

        currentNode.setNextNode(currentNode.getNextNode().getNextNode());
        this.size--;
    }

    public void remove(T data) {

        int[] indexes = findIndexes(data);

        for (int i = 0; i < indexes.length; i++) {
            this.removeIndex(indexes[i]);
        }
    }

    public void set(T data, int index) {
        Node currentNode = get(index);
        currentNode.setData(data);
    }

    public boolean isContain(T data) {
        for (int i = 0; i < this.size; i++) {
            if (this.get(i).getData().equals(data)) {
                return true;
            }
        }

        return false;
    }

    public boolean isEmpty() {
        return this.size == 0;
    }

    public int size() {
        return this.size;
    }

    public void print() {

        for (int i = 0; i < this.size; i++) {
            System.out.print(this.get(i).getData() + " ");
        }
        System.out.println("size:" + this.size);
    }

    class Node {
        T data;
        Node nextNode;

        public Node(T data, Node nextNode) {
            this.data = data;
            this.nextNode = nextNode;
        }

        public Node(T data) {
            this.data = data;
        }

        public T getData() {
            return this.data;
        }

        public void setData(T data) {
            this.data = data;
        }

        public Node getNextNode() {
            return this.nextNode;
        }

        public void setNextNode(Node nextNode) {
            this.nextNode = nextNode;
        }
    }

}